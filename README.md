This is a small Processing app for logging timestamps to a google doc.

I developed this program to help me keep track of my time and fill out my timesheet every 2 weeks.

USAGE:
A) Download or checkout this repository to your Processing directory. The first time you run the sketch
it will prompt you for some Temboo account settings as well as Google account settings.

B) You can go to temboo.com to set up an account, then visit the "My Account" page and click "Application Keys" in the menu on the left.
use the name (default 'myFirstApp') as the Temboo App Key Name, and the associated key as the Temboo App Key Value. 

C) The sketch also requests your google username and password. If you use two-step authentication for your google services, then you will need to generate and use an
app-specific password. This can be done by 
	i)   Going to your google account (from most Google pages, click your avatar in the top-right corner and select "Account").
	ii)  On the account page, select "Security" from the menu on the left
	iii) On the bottom of that page (under "connected applications and sites") click "Manage Access".
	iv)  You will be prompted for your password again, then you can click "generate password" near the bottom of the page to create a specific password to use with google 
services through your temboo account. 
	v)   Take this generated password and enter in in the "Google Password" box of the time_logger_p5 sketch.

D) You will need to point the sketch at the specific Google Spreadsheet that you want to log your timestamps to. There is a template provided here: https://drive.google.com/previewtemplate?id=0Au1jvUiMMszidFRvZzBTT1BvZHJ5UklKUjVndXlyT0E&mode=public

E) Once you have filled out the settings, you can click 'Save' to save those settings and then close the settings drop-down by clicking the bar labelled "Settings" at the top of the processing sketch window.

F) For each task you want to keep track of, just open the "add task" toolbar and fill in the information (everything is optional).
