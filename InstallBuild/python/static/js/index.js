var hostname="http://sdpod-auto1:8001"
function installBuildForm(){
   form1= document.getElementById("installBuildForm")
    form1.style.display = "block";

}

function cancelInstall(){
   form1= document.getElementById("installBuildForm")
    form1.style.display = "none";

}

function GetAllRunningBuilds(){
window.location.href = hostname+"/GetAllRunningBuilds";
}

function GetallBuilds(){
window.location.href = hostname+"/GetallBuilds";


function StartBuild(id) {
nameContainer=id
alert(nameContainer)
window.location.href = hostname+"/StartBuild/"+nameContainer;

}



function StopBuild(id) {
nameContainer = id.split("/")
nameContainer=nameContainer[nameContainer.length -2]+"+++"+nameContainer[nameContainer.length -1]
window.location.href = hostname+"/StopBuild/"+nameContainer;

}
