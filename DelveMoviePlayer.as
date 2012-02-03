package
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.text.TextField;
	import fl.controls.Button;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import DelveEvent;

  public class DelveMoviePlayer extends MovieClip
  {

    //-------------------------------------------------------------
    //
    // Constants - Static - Private
    //
    //-------------------------------------------------------------
    private static  const BUTTON_PADDING:int = 5;
    private static  const DEFAULT_VOLUME:int = 0;
    private static  const MAX_VOLUME:int = 99;
    private static  const TEXT_HEIGHT:int = 15;
    private static  const MAX_PROGRESS:int = 100000;


    //-------------------------------------------------------------
    //
    // Variables - Private
    //
    //-------------------------------------------------------------

    private var delvePlayer:DelvePlayer;

    private var controlsContainer:Sprite;

    private var progressIsDragging:Boolean = false;

    private var channelId:String = "441bddc0c5b2459aa8a5e8725208d21a"; //"23db22ec9aa04bc3bab899c87de77f5c";
	
	private var loopDelay:Number = 5000;
	
	var mbContent:Sprite;
	var txtFormat:TextFormat;
	
	

    //-------------------------------------------------------------
    //
    // Constructor
    //
    //-------------------------------------------------------------
    public function DelveMoviePlayer():void
    {
      try
      {
        var keyStr:String;
        var valueStr:String;
        var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
        for (keyStr in paramObj)
        {
          valueStr = String(paramObj[keyStr]);
          switch (keyStr)
          {
            case "channelId":
              channelId = valueStr;
              break;
          }
        }
      }
      catch (error:Error)
      {
      }

      if (!delvePlayer)
      {
        // create the instance of the movie player
        // this imports the chromeless .swf from Delve Networks in which the movie plays
        // and with which you will interact
        //delvePlayer = new DelvePlayer();
		
		var fv:Object = new Object();
		fv["autoplay"] = true;
		fv["channelId"] = channelId;
		
//		var delvePlayer:DelvePlayer = new DelvePlayer(new DelvePlayerConfig(fv));
  		delvePlayer = new DelvePlayer(new DelvePlayerConfig(fv));
     
	    delvePlayer.addEventListener(DelveEvent.EVENT_MEDIA_COMPLETE, mediaCompleteHandler, false, 0, true);
        addChildAt(delvePlayer, 1);
		
        // position the chromeless player inside of your .swf
        delvePlayer.y = 15;
        delvePlayer.x = 0;

        // set the size of the chromeless player
        delvePlayer.width = 300;
        delvePlayer.height = 170;

        // set the default volume
        delvePlayer.volume = 0 / 100;

      }

      // create the local controls that will control the imported chromeless player
      createControls();

    }


    //-------------------------------------------------------------
    //
    // Methods - Private
    //
    //-------------------------------------------------------------
    private function createControls():void
    {
    controlsContainer = new Sprite();
	  
		var alphaUp = 0; 
		var alphaDown = 0.8;
		var alphaOver = 0.4;
		var alphaOut = alphaUp;
		
		//var txtFormat:TextFormat = new TextFormat();  
			txtFormat = new TextFormat();  
	
			txtFormat.color = 0x015595;   
			txtFormat.size = 7; 
			txtFormat.font = "Verdana";
			


		var restartButton:SimpleButton = new SimpleButton();
			restartButton.x = 0;
			restartButton.y = 0;
			var rsContent:Sprite = new Sprite();
			var rsTextField:TextField = new TextField();
				rsTextField.name = "textField";
				rsTextField.text = "  RESTART w/SOUND  ";
				rsTextField.autoSize = TextFieldAutoSize.LEFT;  
				rsTextField.setTextFormat(txtFormat);  
				rsContent.addChild(rsTextField);
				
				draw(rsContent.graphics, 0xFFFFFF, alphaUp, rsContent.width);

				restartButton.upState = rsContent;
				restartButton.overState = rsContent;
				restartButton.downState = rsContent;
				restartButton.hitTestState = rsContent;      
				restartButton.addEventListener(MouseEvent.MOUSE_OVER, onRSButtonMouseOver);
				restartButton.addEventListener(MouseEvent.MOUSE_DOWN, onRSButtonMouseDown);
				restartButton.addEventListener(MouseEvent.MOUSE_OUT, onRSButtonMouseOut);
				restartButton.addEventListener(MouseEvent.MOUSE_UP, onRSButtonMouseUp);
				restartButton.addEventListener(MouseEvent.CLICK, playButton_clickHandler);
				controlsContainer.addChild(restartButton);

	  	var muteButton:SimpleButton = new SimpleButton();
			muteButton.x = restartButton.x + restartButton.width + BUTTON_PADDING;
			muteButton.y = 0;
			mbContent = new Sprite();

			var mbTextField:TextField = new TextField();
				mbTextField.name = "textField";
				mbTextField.text = "  MUTE  ";
				mbTextField.autoSize = TextFieldAutoSize.LEFT;  
				mbTextField.setTextFormat(txtFormat);  
				mbContent.addChild(mbTextField);
				draw(mbContent.graphics, 0xFFFFFF, alphaUp, mbContent.width);

				muteButton.upState = mbContent;
				muteButton.overState = mbContent;
				muteButton.downState = mbContent;
				muteButton.hitTestState = mbContent;
				muteButton.addEventListener(MouseEvent.MOUSE_OVER, onMuteButtonMouseOver);
				muteButton.addEventListener(MouseEvent.MOUSE_DOWN, onMuteButtonMouseDown);
				muteButton.addEventListener(MouseEvent.MOUSE_OUT, onMuteButtonMouseOut);
				muteButton.addEventListener(MouseEvent.MOUSE_UP, onMuteButtonMouseUp);
				muteButton.addEventListener(MouseEvent.CLICK, unmuteButton_clickHandler);
				
			
	  
			
		controlsContainer.x = 0;//(stage.stageWidth - controlsContainer.width) / 2;
		controlsContainer.y = 0;//stage.stageHeight - BUTTON_HEIGHT - BUTTON_PADDING;
		addChild(controlsContainer); 


				var ctButton:SimpleButton = new SimpleButton();
				var clickTag = new Sprite();
			
				ctButton.x = 0;
				ctButton.y = 15;
	
				clickTag.graphics.clear();
				clickTag.graphics.beginFill(0xFFFFFF, 0.0)
				clickTag.graphics.drawRect(0, 0, 300, 235);
				clickTag.graphics.endFill();
				
				ctButton.upState = clickTag;
				ctButton.overState = clickTag;
				ctButton.downState = clickTag;
				ctButton.hitTestState = clickTag;  
				addChild(ctButton);
	
	
				//Event listener for clickable object
				ctButton.addEventListener(MouseEvent.CLICK,clickTagHandler);			
		
			function clickTagHandler(e:MouseEvent):void{
				navigateToURL(new URLRequest(root.loaderInfo.parameters.clickTAG), "_blank");
			}
			
		

		// HOVER - MUTE BUTTON
	function onMuteButtonMouseOver(e:MouseEvent):void
		{draw(mbContent.graphics, 0xFFFFFF, alphaOver, mbContent.width);}// end function
		
	function onMuteButtonMouseDown(e:MouseEvent):void
		{draw(mbContent.graphics, 0xFFFFFF, alphaDown, mbContent.width);}// end function
		
	function onMuteButtonMouseUp(e:MouseEvent):void
		{draw(mbContent.graphics, 0xFFFFFF, alphaUp, mbContent.width);}// end function
		
	function onMuteButtonMouseOut(e:MouseEvent):void
		{draw(mbContent.graphics, 0xFFFFFF, alphaOut, mbContent.width);}// end function
		
		// HOVER - RESTART BUTTON
	function onRSButtonMouseOver(e:MouseEvent):void
		{draw(rsContent.graphics, 0xFFFFFF, alphaOver, rsContent.width);}// end function
		
	function onRSButtonMouseDown(e:MouseEvent):void
		{draw(rsContent.graphics, 0xFFFFFF, alphaDown, rsContent.width);}// end function
		
	function onRSButtonMouseUp(e:MouseEvent):void
		{draw(rsContent.graphics, 0xFFFFFF, alphaUp, rsContent.width);}// end function
		
	function onRSButtonMouseOut(e:MouseEvent):void
		{draw(rsContent.graphics, 0xFFFFFF, alphaOut, rsContent.width);}// end function
		
		
	function draw(graphics:Graphics, color:uint, alpha:Number, w:Number):void
		{
			graphics.clear();
			graphics.beginFill(color, alpha)
			graphics.drawRect(0, 0, w, 15);
			graphics.endFill();
		
		}// end function
		

	function playButton_clickHandler(event:MouseEvent):void
		{
			delvePlayer.seekToRatio(0/100);
			delvePlayer.play();
			delvePlayer.volume = 100/100;
			controlsContainer.addChild(muteButton);
			muteButton.removeEventListener(MouseEvent.CLICK, unmuteButton_clickHandler);
			muteButton.addEventListener(MouseEvent.CLICK, muteButton_clickHandler);
				toggleMuteButton("  MUTE  ");
		}
		
	function pauseButton_clickHandler(event:MouseEvent):void
		{
			delvePlayer.pause();
		}
	
	function muteButton_clickHandler(event:MouseEvent):void
		{
			delvePlayer.volume = 0/100;
			muteButton.removeEventListener(MouseEvent.CLICK, muteButton_clickHandler);
			muteButton.addEventListener(MouseEvent.CLICK, unmuteButton_clickHandler);
				toggleMuteButton("  UNMUTE  ");
		}
	
	function unmuteButton_clickHandler(event:MouseEvent):void
		{
			delvePlayer.volume = 100/100;
			muteButton.removeEventListener(MouseEvent.CLICK, unmuteButton_clickHandler);
			muteButton.addEventListener(MouseEvent.CLICK, muteButton_clickHandler);
				toggleMuteButton("  MUTE  ");
		}
			
    }    
	
	function toggleMuteButton(status:String):void {
		var textField:TextField = TextField(mbContent.getChildByName("textField"));
			textField.text = status;
			textField.setTextFormat(txtFormat);  
	}
	
	function mediaCompleteHandler(event:DelveEvent):void
		{
			delvePlayer.volume = 0/100;
			delvePlayer.pause();
			toggleMuteButton("  UNMUTE  ");
			var timer:Timer = new Timer(loopDelay);
				timer.addEventListener(TimerEvent.TIMER, onTimer);

			function onTimer(evt:TimerEvent):void
				{
					delvePlayer.loadChannel(channelId, true);
					timer.removeEventListener(TimerEvent.TIMER, onTimer);

				}
			timer.start();
		}
		
  }
}
