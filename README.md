#Time Logger
This is a small Processing app for logging timestamps to a google doc. It is strongly recommended that you have [2-step authentication](https://support.google.com/accounts/answer/180744?hl=en) enabled for your Google account to use this software, otherwise you may get e-mails about suspicious activity in you Google account.

I developed this program to help me keep track of my time and fill out my timesheet every 2 weeks.

##Setup
1. Download or checkout this repository to your Processing directory. The first time you run the sketch
it will prompt you for some Temboo account settings as well as Google account settings.
2. You can go to temboo.com to set up an account, then visit the "My Account" page and click "Application Keys" in the menu on the left.
use the name (default 'myFirstApp') as the Temboo App Key Name, and the associated key as the Temboo App Key Value. 
3. The sketch also requests your google username and password. If you use two-step authentication for your google services **(strongly recommended)**, then you will need to generate and use an
app-specific password. This can be done by 
   * Going to your google account (from most Google pages, click your avatar in the top-right corner and select "Account").
   * On the account page, select "Security" from the menu on the left
   * Near the bottom of that page (next to "connected applications and sites") click "Review Permissions".
   * You will be prompted for your password again, then you can click "generate password" near the bottom of the page to create a specific password to use with google services through your temboo account. 
   * Take this generated password and enter in in the "Google Password" box of the time logger program.
4. You will need to point the sketch at the specific Google Spreadsheet that you want to log your timestamps to. There is a template provided here: https://drive.google.com/previewtemplate?id=0Au1jvUiMMszidFRvZzBTT1BvZHJ5UklKUjVndXlyT0E&mode=public
5. Once you have filled out the settings, you can click 'Save' to save those settings and then close the settings drop-down by clicking the bar labelled "Settings" at the top of the processing sketch window.
6. For each task you want to keep track of, just open the "add task" toolbar and fill in the information (everything is optional).
