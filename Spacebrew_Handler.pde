import spacebrew.*;

String server="localhost";//"sandbox.spacebrew.cc";//
String name="quin's Timekeeper";
String description = "";

public class Spacebrew_Handler{
  time_logger_p5 pApplet;
  Spacebrew spacebrew;
  XMLElement tasks;
  
  public Spacebrew_Handler(time_logger_p5 pApplet){
    this.pApplet = pApplet;
    spacebrew = new Spacebrew(this);
  }
  
  public void setupClient(XMLElement data){
    spacebrew.addSubscribe("current task", "string");
    spacebrew.addPublish("current task", "");
    for(XMLElement list : data.getChildren()){
      if (list.getElement().equals("tasks")){
        tasks = list;
        for(XMLElement task : list.getChildren()){
          addTask(task);
        }
        break;
      }
    }
    spacebrew.connect("ws://"+server+":9000", name, description);
  }
  
  public void addTask(XMLElement task){
    spacebrew.addSubscribe(task.getAttribute("DisplayName"), "boolean");
    spacebrew.addPublish(task.getAttribute("DisplayName"), false);
  }
  
  public void onBooleanMessage( String name, boolean value ){
    println("got bool message "+name +" : "+ value);
    if (!value){
      return;
    }
    for(XMLElement task : tasks.getChildren()){
      if (task.getAttribute("DisplayName").equals(name)){
        pApplet.logTime(task);
        break;
      }
    }
  }
  
  public void pubTask(XMLElement task){
    spacebrew.send(task.getAttribute("DisplayName"), true);
    spacebrew.send("current task", task.getAttribute("DisplayName"));
  }
  
  public void onStringMessage(String name, String value){
    println("got string message " + name + " : " + value);
    //first check against display names
    //then check against proj. numbers
    //then check against official names
    String[] attributes = {"DisplayName", "JobNumber", "OfficialName"};
    XMLElement[] matches = new XMLElement[attributes.length];
    for(XMLElement task : tasks.getChildren()){
      for(int i = 0; i < attributes.length; i++){
        if (task.getAttribute(attributes[i]).equals(value)){
          matches[i] = task;
          //break out of inner loop, continue iterating through all tasks
          break;
        }
      }
    }
    
    for(int i = 0; i < matches.length; i++){
      if (matches[i] != null){
        pApplet.logTime(matches[i]);
        break;
      }
    }
  }
}
