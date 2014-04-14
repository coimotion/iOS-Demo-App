iOS Demo App 
==============
本文件透過App的開發來說明COIMOTION API與COIMOTION SDK的使用，開發者如果對COIMOTION還不熟悉的話，可以先閱讀"[COIMOTION概念介紹](http://www.slideshare.net/BenLue/coimotion)"與"[第一次使用COIMOTION](http://www.slideshare.net/BenLue/coimotion-32567567)就上手"，對COIMOTION的概念與COIMOTION API服務有初步的了解。

#Demo App簡介

此Demo app為"瘋藝文"，以高雄市的藝文活動為主，輔以高雄市公車資訊，讓使用者在查詢活動的過程中可以順便查詢可到達活動地點附近的公車路線與即時資訊，因此在開發app之前，先登入COIMOTION網站，建立此app與設定欲使用的內容集與模組資源，在這demo中，建立app的appCode為"demoApp"，並啟用了core模組還有引用了twShow與twCtBus兩個內容集。另外有開放源碼供開發者使用，有興趣的開發者可以到此[下載](https://github.com/coimotion/iOS-Demo-App)。  

此app執行時會先出現登入畫面，如果初次使用的話，請切換至註冊畫面進行註冊，註冊/登入成功後即可進入app主功能頁，只要token還是有效的，使用者再次開啟app時仍可維持登入狀態；主畫面列有九大藝文分類，使用者點擊即可進入列表，此處預設列出一週內的該類的活動，使用者可透過點擊標題或是右瀏覽按鈕選擇不同的類別或是時間區間來查詢活動，點擊活動的話會進入活動資訊的畫面，此處會詳列活動資訊，如有提供售票網站的話，會有連結到網站的按鈕，如果該活動不止一場的話，右瀏覽按鈕的點選以時間來查詢場次資訊，最後有地圖按鈕，點擊後會開啟地圖頁面並標示活動地點與其附近的公車站牌，點選公車站牌時會顯示該站牌名稱並查詢顯示經過該站牌的路線，右瀏覽按鈕可進入公車路線清單，此處會列出經過標示出的站牌的所有路線，點擊路線後會顯示該路線目前的即時到站資訊。

#使用COIMOTION iOS SDK

[COIMOTION SDK](http://tw.coimotion.com/bkIndexPapers/view/7743?id=21366)目前提供開發者http request相關的函式，包裝開發過程中對token/app_key的操作，開發者在處理資料時就不用另外處理token的更新，另外提供註冊/登入的API function，會以salt的方式強化使用者的密碼再送出，如果開發者要在其它平台提供相同的會員服務的話，要注意登入時的密碼處理。
COIMOTION SDK可由此[下載](http://tw.coimotion.com/wcoim/SDK/COIMOTION-SDK-iOS.zip)，解壓縮後資料夾(版本號)中會有api使用文件(iOScoimSDK文件.pdf)、SDK標頭檔(coimSDK.h)與兩個包含libcoimSDK.a的資料夾，分別是給實機/模擬器用的lib，使用時只要將標頭檔與lib檔新增至xcode project中，並在"Supporting Files"中的[_project-name_]-Prefix.pch中加入#include "coimSDK.h"，如此coimSDK.h便可以在此project下生效，不用在每個class中去include；另外COIMOTION API的使用會需要app code產生url與app key來做為驗證，SDK在初始化時會從app的[project-name]-info.plist中讀取，因此開發者使用SDK時要先在plit中新增coim_app_key(程式金鑰)與coim_app_code(app代碼)兩行，值可至COIMOTION網站的"APP管理"下的"基本資料"取得。  
  
#App中的API/SDK使用  

此段落以demo app來做說明，讀者可搭配下載的程式碼一同閱讀會更容易了解。
  
##‧MainViewController  
  
App第一個執行的view，在此會檢查使用者是否是登入狀態，因此在viewDidLoad中對SDK初始化([coimSDK initSDK:^(NSError *err){}])，如果失敗的話可以在傳入的block中取得失敗資訊，接下來以sendTo:withParameter:delegate來做token的檢查，使入的參數為{}，url為"core/user/profile"，並實作coimConnectionDidFinishLoading:withData:委派函式以處理API回傳的資料，如果token是無效的，API會回傳以下內容：  

>{  
>    errCode = 0;  
>    message = Ok;  
>    value = {  
>        dspName = guest;  
>        isGuest = 1;  
>    };  
>}  
  
如果是guest的話就顯示登入畫面，反之就進入app主功能畫面。  
  
##‧LoginViewController  
  
此view controller為登入與註冊的處理，使用者可根據是否註冊來選擇切換功能，按下按鈕後會根據功能選擇呼叫(loginTo:withParameter:delegate或是registerWithParameter:delegate)，另外除實作coimConnectionDidFinishLoading:withData:來判斷登入/註冊成功外，同時實作了coimConnection:didFailWithError:來顯示登入或註冊時的錯誤訊息。登入成功會接到以下的API回應：  

>{  
>    errCode = 0;  
>    message = "Login Ok.";  
>    token = f700e0396cd48298c0b314592490bbce;  
>}  
  
由於SDK內部已處理過token，開發使用SDK處理登入/註冊的話，即可忽略此處的token處理，直接視為登入成功，進入app主畫面。  
  
##‧ViewController  
  
此view controller為以catID(展覽類別ID，可由"twShow/show/catList"取得，此app已選定要查詢分類所以事先準備好)與展覽期間(此app以今天開始的一週為預設)為查詢條件，以"twShow/show/byCity/[ctID]"來查詢高雄市(ctID: 15)的藝文活動，所以sendTo:withParameter:delegate使用的參數為：{"cat": catID, "fromTm": yyyy-MM-dd, toTm:yyyy-MM-(dd+7)}，url為"twShow/show/byCity/15"來查詢一週內高雄市的藝文活動，並在coimConnectionDidFinishLoading:withData:中把取得的資料整理更新側畫面上的table view。
  
##‧DetailViewController  
  
在ViewController中點擊活動後，ViewController會將該活動的spID傳至DetailViewController以發送API至"twShow/show/info/[spID]"取得該活動的詳細資訊，所以sendTo:withParameter:delegate使用的參數為：{"detail": "1"}，url為"twShow/show/info/[spID]"來查詢選取的藝文活動詳細資訊，並在coimConnectionDidFinishLoading:withData:中把取得的資料顯示至畫面。  
  
##‧MapListViewController  
  
DetailViewController中的地圖按鈕可將活動地點的經緯度帶入MapViewController並以綠色大頭針標於地圖上，此經緯度除標示活動地點外，同時用來查詢該地點分近的公車站牌，同樣是使用sendTo:withParameter:delegate，使用的參數為：{"lat": latitude, "lng": longitude}，url為"twCtBus/busStop/search"來查詢該經緯度附近的公車站牌，並在coimConnectionDidFinishLoading:withData:中把取得的資料整理並以紅色大頭針標示至地圖上。
  
點選紅色大頭針時，可取得該站牌的tsID，並以該tsID去查詢經過該站牌的公車路線，使用sendTo:withParameter:delegate，使用的參數為：{}，url為"twCtBus/busStop/routes/tsID"來查詢，在coimConnectionDidFinishLoading:withData:中把取得的路線加至該大頭針的annotation view。  
  
##‧RouteListViewController  
  
此view controller中會帶入MapViewController取得的tsID列表，依序查詢路線並過濾掉重覆的路線再顯示於畫面上，與MapViewController中查詢公車路線的方法一樣，在此就不重覆說明。  
  
##‧RouteViewController  
  
RouteListViewController中點擊table上的路線，會開啟RouteViewController，並將路線的id(brID)傳入，在此用sendTo:withParameter:delegate，使用的參數為：{}，url為"twCtBus/busRoute/next/brID"來查詢該路線的即時資訊，在coimConnectionDidFinishLoading:withData:中把取得的路線資料(站名與預計到站時間(如果有的話))顯示於畫面。  
  
##‧SettingViewController  
  
此view controller中提供了登出的功能，登出是使用SDK中的logoutFrom:delegate，呼叫此API時，SDK會先將儲存於plist中的token清除，並發送API至"core/user/logout"，此時server端亦同步註銷使用中的token，因此不論成功失敗，app端皆可視為登出，在coimConnectionDidFinishLoading:withData:與coimConnection:didFailWithError:中皆直接在app中顯示登入畫面。

