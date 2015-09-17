  /*********************************************************************/
  /*              Kaleidoscope, for Laptop Ensemble                    */
  /*                                                                   */
  /* Version 1.0                                                       */
  /*                                                                   */
  /* David Gordon                                                      */
  /* http://www.spatializedmusic.com/                                  */
  /*                                                                   */
  /*********************************************************************/

/**************************** Installation ************************/
/*
/* See Instructions.pdf for installation instructions for the required external libraries:
/* TheMidiBus, OscP5, Obsessive Camera Direction (OCD) Library
/*
/****************************************************************/

/**************************** Quick Setup ****************************/
/*
/* For each machine:
/*    
/* 1. Follow instructions under General Setup, Network Setup and Music Setup sections below.
/* 2. Connect to WIFI 
/* 3. If this machine is the server, turn on File Sharing. 
/*      If this machine is a client, in the Finder, choose Go > "Connect to Server" and select the server's name.
/*
/*  See Instructions.pdf for full setup instructions.
/*
/*********************************************************************/

void setup()
{
  size(1080, 720, P3D);      // Sets size of window and renderer to use (P3D)
  frameRate(25);             // Sets frame rate
  
  /************* General Setup ***************
  * Set numPerformers to the number of performers in the ensemble:    */
  numPerformers = 3;     
  
  /*************** Network Setup *************
  * Set ipAddress  to your computer's IP Address.  (under System Preferences > Network)
  * Set serverIPAddress to the IP address of the server:                     */
  ipAddress = "192.168.1.138";   //  Mac Pro          
  serverIPAddress = "192.168.1.128";                   // Note: Must be same as "ipAddress" on server machine

  //serverIPAddress = "192.168.1.138"; // Mac Pro
  //serverIPAddress = "192.168.1.128";   // MacBook Pro     
  //serverIPAddress = "192.168.1.126"; // MacBook   
  ipAddress = "192.168.1.138"; // Mac Pro
 // ipAddress = "192.168.1.128";  // MacBook Pro     
  //ipAddress = "192.168.1.126"; // MacBook   
 
  /***************** Music Setup ***************
  *                                                             Choose Module:
  * KaleidoscopeModule.VISUALIZER  (Server Default)    KaleidoscopeModule.SONIFIER         KaleidoscopeModule.CONTROLLER
  *                                                                                                                                                */                                                                                               
  currentModule = KaleidoscopeModule.SONIFIER;      

  /*                                                             Choose Process:
  * KaleidoscopeProcess.ARPEGGIO     KaleidoscopeProcess.OSTINATO       KaleidoscopeProcess.ADDITIVE      KaleidoscopeProcess.SUBTRACTIVE                                    
  *                                                                                                                                                */                                                                                               
  currentProcess = KaleidoscopeProcess.OSTINATO;      
 
  /************** Music Settings *****************/
  tonicKey = 0;            // Initial tonic key (0=C, 1=C#, 2=D,...)
  timbre = 1;              // Initial timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)
  droneTimbre = 2;         // Initial drone timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)
  scaleMode = 0;           // Inital scale mode (0 = Ionian, 1 = Dorian, 2 = Phrygian...)
  tempo = 18;  // Initial tempo (in frames per beat)
  
  setupKaleidoscope();        // Perform the setup functions
}

void draw()
{
  if(currentModule != KaleidoscopeModule.SONIFIER)
  {
    background(backgroundColor);    // Set background color each frame
  }
  else
  {
    background(0);                  // Draw background each frame
    lineMode = true;
  }

  if (isServer && waitingForPerformers)
  {
    if(numConnected >= numPerformers)
    {
      waitingForPerformers = false;
    }
    else
    {
       fill(150, 155, 255);
       textSize(28);
       text("Waiting for performers", 100, 50, -250);

      if(debug && frameCount % 150 == 0)
      {
        println("Waiting for performers..."); 
        println("Currently are "+(numConnected-1)+" performers connected..."); 
      }
    }
  }

  if(pieceStarted && !stopPiece)                // Wait for the server before starting
  {
    switch(currentModule)
    {
      case VISUALIZER:
        vizField.update();
        vizField.display();
        
        updateCamera();
        camera.feed();
        break;
       
      case SONIFIER:
        noteField.update();
        noteField.display();
        
        sonificationArray.update();
        sonificationArray.display();
        
        updateCamera();
        camera.feed();
        break;
        
      case CONTROLLER:
        displayInfo(); 
        break;
    }
    
    updateMusic();
    playMusic();
  }
  else if(!pieceStarted)
  {
     fill(150, 155, 255);
     textSize(320);
     pushMatrix();
     rotateY(radians(180));
     if(debug)
     {
      text("Debug Mode:", 50, -150, -250);
      text("Waiting to start...", 50, 50, -250);
      text("Push '/' key to enter test mode...", 50, 350, -250);
     }
     popMatrix();
  }
  
  if(currentModule == KaleidoscopeModule.VISUALIZER || currentModule == KaleidoscopeModule.SONIFIER)
  {
    updateCamera();
    camera.feed();
  }
  
  if(stopPiece && notesPlaying == 0 && dronesPlaying == 0)
  {
    stopPiece();
  }
  
  if(pieceStopped)
  {
    stop(); 
  }
}

void stop()
{
  super.stop();
}

