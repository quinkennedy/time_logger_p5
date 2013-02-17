//TEST:

//TODO:
// - have spacebrew server config-able to only listen to certain IPs (or at least localhost)

//make error and success feedback more user friendly
// - even just wrapping the output to fit on the screen

//make spreadsheet into a template that ppl can copy

//fix error that occurs when toggling off a radio button
// - or don't allow them to toggle, but do allow them to be re-clicked
// - to trigger a new entry

//don't let time changes mess up program (always log meridian time?)
// - check Java time functions

//allow tasks to be added by hitting 'enter'
//have tasks auto-populate from google spreadsheet
//add scrollback buffer to console output
//default to 'out-of-office' on startup (or read from google doc?)
//make temboo runner thread safe


import controlP5.*;
import com.temboo.core.TembooSession;
import com.temboo.Library.Google.Spreadsheets.*;
import com.temboo.Library.Google.Spreadsheets.AppendRow.*;
import proxml.*;
import org.apache.commons.lang3.StringEscapeUtils;
import gifAnimation.*;

TembooSession session;
ControlP5 cp5;
RadioButton rb5;
Accordion ac5;
XMLElement data, tasks, messages;
XMLInOut xmlInOut;
boolean bRunningTemboo = false;
boolean bRunTemboo = true;
Spacebrew_Handler spacebrewHandler;
Gif gifLoading;

String sAccountName;
String sAppKeyName;
String sAppKeyValue;
String sGoogAccountName;
String sGoogPassword;
String sSpreadsheetName;
int itemsPerRow = 1;

String[] log = new String[10];
String[] s_arrSettings = {"Temboo Account Name", "Temboo App Key Name", "Temboo App Key Value", "Google Username", "Google Password", "Google Spreadsheet"};
String[] s_arrTasks = {"Display Name", "Official Name", "Job Number", "Client"};

void setup(){
  readXMLFile();
  //size(400, 30+27*tasks.size()+14*log.length);
  size(400, 100+27*10+14*10);
  spacebrewHandler = new Spacebrew_Handler(this);
  gifLoading = new Gif(this, "loading.gif");
  gifLoading.loop();
}

void setupUI(){
  cp5 = new ControlP5(this);
  initInputs();
  populateInputs();
  initButtons();
}

void initInputs(){
     
  cp5.addTextfield("note")
      .setPosition(10, 25)
      ;
      
  Group settings = cp5.addGroup("settings")
                      .setBackgroundColor(color(0, 150))
                      .setBackgroundHeight((s_arrSettings.length+1)*40 + 10);
  
  int i = 10;
  for(String s : s_arrSettings){
    cp5.addTextfield(s)
        .setPosition(15, i)
        .moveTo(settings)
        .setAutoClear(false);
        //.setPasswordMode(s.equals("Google Password"));
    i += 40;
  }
  cp5.addButton("save", 0, 100, i, 100, 20)
      .moveTo(settings)
      .setColorBackground(color(255, 0, 255))
      ;
    
  Group addTask = cp5.addGroup("add task")
                      .setBackgroundColor(color(0, 150))
                      .setBackgroundHeight((s_arrTasks.length+1)*40 + 10);
  i = 10;
  for(String s : s_arrTasks){
    cp5.addTextfield(s)
        .setPosition(15, i)
        .moveTo(addTask)
        .setAutoClear(false)
        ;
    i += 40;
  }
  cp5.addButton("add", 0, 100, i, 100, 20)
      .moveTo(addTask)
      ;
      
  ac5 = cp5.addAccordion("acc")
            .addItem(settings)
            .addItem(addTask)
            .setWidth(300)
            .setPosition(width - 300 - 10, 0)
            .setCollapseMode(Accordion.MULTI);
       
}

void readXMLFile(){
  xmlInOut = new XMLInOut(this);
  try{
    xmlInOut.loadElement("data.xml");
  } catch(Exception e){
    xmlEvent(new XMLElement("data"));
  }
}

void populateInputs(){
  boolean allPopulated = true;
  for(String s : s_arrSettings){
    String attr = removeSpaces(s);
    if (data.hasAttribute(attr)){
      cp5.get(Textfield.class, s).setText(data.getAttribute(attr));
    } else {
      allPopulated = false;
    }
  }
  
  if (!allPopulated){
    //default to the settings panel open
    cp5.get(Group.class, "settings").open();
  } else {
    settingsXmlToVars();
  }
}

void settingsXmlToVars(){
  sAccountName = data.getAttribute("TembooAccountName");
  sAppKeyName = data.getAttribute("TembooAppKeyName");
  sAppKeyValue = data.getAttribute("TembooAppKeyValue");
  sGoogAccountName = data.getAttribute("GoogleUsername");
  sGoogPassword = data.getAttribute("GooglePassword");
  sSpreadsheetName = data.getAttribute("GoogleSpreadsheet");
    
  try{
    session = new TembooSession(sAccountName, sAppKeyName, sAppKeyValue);
  } catch (TembooException te){
    addLog("exception: " + te);
  }
}

void xmlEvent(XMLElement element){
  data = element;
  for(XMLElement child : data.getChildren()){
    if (child.getElement().equals("tasks")){
      tasks = child;
    } else if (child.getElement().equals("messages")){
      messages = child;
    }
  }
  if (tasks == null){
    tasks = new XMLElement("tasks");
    data.addChild(tasks);
    String[] defaults = {"Out Of Office", "Lunch"};
    for(String d : defaults){
      XMLElement dTask = new XMLElement("task");
      dTask.addAttribute("DisplayName", d);
      for(int i = 1; i < s_arrTasks.length; i++){
        dTask.addAttribute(s_arrTasks[i], "");
      }
      tasks.addChild(dTask);
    }
  }
  if (messages == null){
    messages = new XMLElement("messages");
    data.addChild(messages);
  }
  saveXML();
}

void addMessage(String s){
  XMLElement message = new XMLElement("message");
  message.addAttribute("text", StringEscapeUtils.escapeXml(s));
  message.addAttribute("success", 0);
  messages.addChild(message);
  saveXML();
  bRunTemboo = true;
}

void saveXML(){
  xmlInOut.saveElement(data, "data.xml");
}

void initButtons(){
  rb5 = cp5.addRadioButton("radioButton")
            .setItemsPerRow(itemsPerRow)
            .setSize(25, 25)
            .setPosition(10, 70);
  XMLElement child;
  for(int i = 0; i < getNumberChildren(tasks); i++){
    child = tasks.getChild(i);
    if (child.getElement().equals("task")){
      addTask(child.getAttribute("DisplayName"), i);
    }
  }
}

void addTask(String s, int i){
  rb5.addItem(s, i);
  int numItems = rb5.getItems().size();
  int numRows = ceil(numItems/(float)itemsPerRow);
  while (numRows > 13 + itemsPerRow){
    rb5.setItemsPerRow(++itemsPerRow)
        .setSize(25, 25)
        .setSpacingColumn((width - itemsPerRow * 25) / itemsPerRow)
        ;
    numRows = ceil(numItems/(float)itemsPerRow);
  }
  if (numRows > 11){
    int size = 25*11/numRows;
    rb5.setSize(size, size);
  }
  
  ac5.bringToFront();
}

void add(){
  XMLElement task = new XMLElement("task");
  for(String s : s_arrTasks){
    Textfield field = cp5.get(Textfield.class, s);
    task.addAttribute(removeSpaces(s), field.getText());
    field.clear();
  }
  String displayName = task.getAttribute("DisplayName");
  addLog("adding task " + displayName);
  tasks.addChild(task);
  addTask(displayName, getNumberChildren(tasks) - 1);
  saveXML();
  addLog("added task " + displayName + " and saved");
  spacebrewHandler.addTask(task);
}

void save(){
  addLog("saving");
  for(String s : s_arrSettings){
    data.addAttribute(removeSpaces(s), cp5.get(Textfield.class, s).getText());
  }
  saveXML();
  settingsXmlToVars();
  addLog("saved");
}

String removeSpaces(String s){
  int i;
  do{
    i = s.indexOf(' ');
    if (i >= 0){
      s = s.substring(0, i) + s.substring(i + 1);
    }
  } while (i >= 0);
  return s;
}

public void controlEvent(ControlEvent theEvent){
  println(theEvent);
  if (theEvent.isFrom(rb5)){
    logTime(tasks.getChild((int)theEvent.getValue()));
  }
  //logTime(theEvent.getController().getName());
}

void draw(){
  if (data != null){
    if (cp5 == null){
      setupUI();
      spacebrewHandler.setupClient(data);
    }
    if (bRunTemboo && !bRunningTemboo){
      startTemboo();
    }
  }
  background(134, 63, 173);
  drawLog(); 
  if (bRunningTemboo){
    image(gifLoading, (width - gifLoading.width)/2, height - 14*8);
  }
}

void drawLog(){
  int i = height - 14*log.length;
  for(String l:log){
    if(l != null){
      text(l, 10, i);
    }
    i += 14;
  }
}

void startTemboo(){
  bRunTemboo = false;
  bRunningTemboo = true;
  //we want to remove all success=true XML here
  for(int i = getNumberChildren(messages) - 1; i >= 0; i--){
    if (messages.getChild(i).getIntAttribute("success") == 1){
      messages.removeChild(i);
    }
  }
  
  saveXML();
  thread("runTemboo");
}

void logTime(XMLElement task){
  addLog("scheduling temboo choreo for: " + task.getAttribute("DisplayName"));
  
  //compile the data for the message
  ArrayList<String> columns = new ArrayList<String>();
  columns.add(getTimestamp());
  for(String s : s_arrTasks){
    columns.add(task.getAttribute(removeSpaces(s)));
  }
  columns.add(cp5.get(Textfield.class, "note").getText());
  
  //format the message as CSV
  String message = "";
  //TODO: test that the quotation marks allow us to add commas in a column
  //TODO: escape quotation marks that may be in one of the columns
  for(String s : columns){
    message += (message.length() == 0 ? "" : ",") + StringEscapeUtils.escapeCsv(s == null || s.length() == 0 ? "-" : s);//"\"" + (s == null || s.length() == 0 ? "-" : s) + "\"";
  }
  addMessage(message);
  spacebrewHandler.pubTask(task);
}

//because for some reason countAllChildren
//counts the element itself too
int getNumberChildren(XMLElement e){
  return e.countChildren();
  //return e.countAllChildren() - 1;
}

String getTimestamp(){
  return month() + "/" + day() + "/" + year() + " " + hour() + ":" + minute() + ":" + second();
}

void addLog(String l){
  println(l);
  for(int i = 0; i < log.length - 1; i++){
    log[i] = log[i+1];
  }
  log[log.length - 1] = l;
}

void runTemboo(){
  int i = 0;
  XMLElement message;
  //first, get to the bottom of all the successfully processed messages
  for(; i < getNumberChildren(messages); i++){
    message = messages.getChild(i);
    if (message.getIntAttribute("success") == 0){
      break;
    }
  }
  
  //now process new messages until we encounter an error
  for(; i < getNumberChildren(messages); i++){
    addLog((getNumberChildren(messages) - i) + " message(s) to process");
    message = messages.getChild(i);
    if (sendTembooMessage(StringEscapeUtils.unescapeXml(message.getAttribute("text")))){
      //DANGER! doing a write to a shared resource!!
      //TODO: look into making this thread safe (along with the saveXML call below)
      message.addAttribute("success", 1);
    } else {
      break;
    }
  }
  
  if (i == getNumberChildren(messages)){
    addLog("all messages processed");
  }
  
  //save the current state (might want to do this after every transaction)
  saveXML();
  bRunningTemboo = false;
}

boolean sendTembooMessage(String message){
  if (sAccountName == null || sAppKeyName == null || sAppKeyValue == null){
    addLog("invalid configuration, fix and restart");
    return false;
  }
  if (session == null){
    addLog("error setting up temboo connection");
    return false;
  } else {
    // Instantiate the choreography, using a previously instantiated TembooSession object, eg:
    // TembooSession session = new TembooSession("ACCOUNT_NAME", "APP_KEY_NAME", "APP_KEY_VALUE");
    AppendRow appendRowChoreo = new AppendRow(session);
    
    // Get an InputSet object for the choreo
    AppendRowInputSet appendRowInputs = appendRowChoreo.newInputSet();
    
    // Set inputs
    appendRowInputs.set_Password(sGoogPassword);
    appendRowInputs.set_Username(sGoogAccountName);
    appendRowInputs.set_SpreadsheetTitle(sSpreadsheetName);
    appendRowInputs.set_SheetName("raw");
    appendRowInputs.set_RowData(StringEscapeUtils.escapeHtml4(message));
    
    // Execute choreography
    try{
      AppendRowResultSet appendRowResults = appendRowChoreo.execute(appendRowInputs);
      //addLog(appendRowResults.toString());
    } catch (TembooException te){
      addLog("error running: " + te);
      return false;
    }
    return true;
  }
}
