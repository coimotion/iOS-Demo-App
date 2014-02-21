iOSAppTemplate
==============
It's a example app for demostrating coimotion API service.

# app structure
* MainViewController 
* LoginViewController
* TableListViewController/MapListingViewController
* DetailedViewController
                                               
## MainViewController
> It tells if the user logged in or no by checking token's validation. If valid, open list view (table/map) to display
> search results of .../geoLoc/search of current location. Else open login view for user to login.
  
## LoginViewController
> User provides the account name and password to log in coimotion server for acquire token.
> If logged in successed, A navigationController will be created with a TableListingViewController 
> (or MapListingViewController), then replace the LoginViewController.
  
## MapListingViewController/TableListingViewController
> Obtained current location then acquire information nearby by .../geoLoc/search API. 
> List the results on a table or map. Click a table row can push a view to show the detail 
> information of the location. Click a pin on map, a bubble display the basic information of the location.
> Click on the disclosure button can push a view to show the detailed information.
