package
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.system.ApplicationDomain;
  import flash.system.LoaderContext;
  import flash.system.Security;
  import flash.system.SecurityDomain;
  import flash.utils.clearInterval;
  import flash.utils.getDefinitionByName;
  import flash.utils.setInterval;


  /**
   * DelvePlayer will dispatch an Event.COMPLETE event when it is useable.  For
   * example, loading a channel will not work until Event.COMPLETE is dispatched.
   *
   * It is suggested to create only one instance of the DelvePlayer due to a known
   * memory leak issue in Flash 9.
   */
  public class DelvePlayer extends Sprite
  {
    //-------------------------------------------------------------
    //
    // Constants - Static - Public
    //
    //-------------------------------------------------------------

    // Live Site URL
    private static const SWF_URL:String = "http://assets.delvenetworks.com/player/current.swf?playerForm=Chromeless";


    //-------------------------------------------------------------
    //
    // Variables - Private
    //
    //-------------------------------------------------------------

    // Internal Data
    private var app:Object = null;
    private var facade:Object = null;
    private var config:DelvePlayerConfig = null;

    private var busyCheckTimer:uint = 0;
    private var lastPositionInMilliseconds:Number = 0;
    private var contentBlockingAdPlaying:Boolean = false;

    // Visual Components
    private var loader:Loader = null;

    private var _lastIsPlaying:Boolean;


    //-------------------------------------------------------------
    //
    // Constructor
    //
    //-------------------------------------------------------------

    public function DelvePlayer(config:DelvePlayerConfig = null)
    {
      Security.allowDomain("*");

      this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);

      this.height = 320;
      this.width = 480;

      this.config = config;

      // HACK: For some odd reason, if you're embedding the DelveNetworksPlayer in a Flex 3 application
      // and BindingUtils/ChangeWatcher was never used, Flex gets into a weird infinite recursion.
      // Uncomment the following if you notice a stack overflow with the following callstack:
      //      at Object$/_hasOwnProperty()
      //      at Object/http://adobe.com/AS3/2006/builtin::hasOwnProperty()
      /*import mx.binding.utils.ChangeWatcher;
      ChangeWatcher.watch(this, ["width"], flexHack).unwatch();*/
    }


    //-------------------------------------------------------------
    //
    // Properties - Public
    //
    //-------------------------------------------------------------

    //-------------------------------------------------------------
    // actualQuality
    //-------------------------------------------------------------

    /**
     * Values: HD, High, Medium, Low, Lowest
     *
     * The current quality that's being streamed.  For example if you're using
     * adaptive streaming, this value may change as you play through the video,
     * depending upon the users CPU/bandwidth.
     */

    public function get actualQuality():String
    {
      return facade ? facade.doGetActualQuality() : null;
    }


    //-------------------------------------------------------------
    // currentChannel
    //-------------------------------------------------------------

    /**
     * The current media.
     */
    public function get currentChannel():Object
    {
      return facade ? facade.doGetCurrentChannel() : null;
    }


    //-------------------------------------------------------------
    // currentChannelList
    //-------------------------------------------------------------

    /**
     * The current channel list.
     */
    public function get currentChannelList():Object
    {
      return facade ? facade.doGetCurrentChannelList() : null;
    }


    //-------------------------------------------------------------
    // currentIndex
    //-------------------------------------------------------------

    /**
     * The current media index playing back (0-based).
     */
    public function get currentIndex():int
    {
      return facade ? facade.doGetCurrentIndex() : 0;
    }


    //-------------------------------------------------------------
    // currentMedia
    //-------------------------------------------------------------

    /**
     * The current media.
     */
    public function get currentMedia():Object
    {
      return facade ? facade.doGetCurrentMedia() : null;
    }


    //-------------------------------------------------------------
    // durationInMilliseconds
    //-------------------------------------------------------------

    private var _durationInMilliseconds:Number = 0;

    /**
     * The current duration in milliseconds of the media.
     */
    public function get durationInMilliseconds():Number
    {
      return _durationInMilliseconds;
    }


    //-------------------------------------------------------------
    // height
    //-------------------------------------------------------------

    private var _height:Number = 0;

    public override function get height():Number
    {
      return _height;
    }


    public override function set height(value:Number):void
    {
      super.height = value;
      this._height = value;

      if (app && loader)
      {
        app.height = _height;
        scaleY = 1;
      }
    }


    //-------------------------------------------------------------
    // isBusy
    //-------------------------------------------------------------

    private var _isBusy:Boolean = false;

    /**
     * The current busy state of the player.  If true, the player is busy
     * and the content is not playing back at the moment.  For example,
     * buffering of the video will cause the player to be in a busy state.
     */
    public function get isBusy():Boolean
    {
      return _isBusy;
    }


    //-------------------------------------------------------------
    // isPlaying
    //-------------------------------------------------------------

    /**
     * The current play state of the player.  If true, the player is playing
     * content, if false, the player has stopped playing content.
     */
    public function get isPlaying():Boolean
    {
      if (facade)
      {
        try
        {
          return facade.doGetCurrentPlayState();
        }
        catch (e:Error)
        {
        }
      }
      return false;
    }


    //-------------------------------------------------------------
    // isReady
    //-------------------------------------------------------------

    /**
     * Determine if the DelvePlayer is ready
     */
    public function get isReady():Boolean
    {
      return facade != null;
    }


    //-------------------------------------------------------------
    // positionInMilliseconds
    //-------------------------------------------------------------

    /**
     * The current position in milliseconds of the media.
     */
    public function get positionInMilliseconds():Number
    {
      return facade ? facade.doGetPlayheadPositionInMilliseconds() : 0;
    }


    //-------------------------------------------------------------
    // quality
    //-------------------------------------------------------------

    /**
     * The current selected quality: Auto, HD, High, Medium, Low, Lowest
     *
     * If the value is "Auto", then that means it'll attempt to use adaptive
     * streaming when possible.  Adaptive streaming will only work if the initial
     * flash app was compiled in Flash 10.  If Flash 9, "Auto" will result in
     * a bandwidth test in the beginning and will not utilize adaptive streaming.
     *
     * If the other qualities are set, adaptive streaming will not be used.
     */
    public function get quality():String
    {
      return facade ? facade.doGetQuality() : null;
    }


    public function set quality(value:String):void
    {
      if (facade)
      {
        facade.doSetQuality(value);
      }
    }


    //-------------------------------------------------------------
    // volume
    //-------------------------------------------------------------

    private var _volume:Number = 0.5;


    /**
     * Volume of the player. Valid values are from 0 to 1.
     */
    public function get volume():Number
    {
      return _volume;
    }


    public function set volume(value:Number):void
    {
      if (value < 0)
      {
        value = 0;
      }
      else if (value > 1)
      {
        value = 1;
      }

      _volume = value;

      if (facade)
      {
        facade.doSetVolume(value);
      }
    }


    //-------------------------------------------------------------
    // width
    //-------------------------------------------------------------

    private var _width:Number = 0;

    public override function get width():Number
    {
      return _width;
    }


    public override function set width(value:Number):void
    {
      super.width = value;
      _width = value;

      if (app && loader)
      {
        app.width = _width;
        scaleX = 1;
      }
    }


    //-------------------------------------------------------------
    //
    // Methods - Public
    //
    //-------------------------------------------------------------

    /**
     * Parameters:
     *    ratio - A value from 0 to 1
     **/
    public function seekToRatio(ratio:Number):void
    {
      if (facade)
      {
        facade.doSeekToRatio(ratio);
      }
    }


    public function seekToSecond(second:Number):void
    {
      if (facade)
      {
        facade.doSeekToSecond(second);
      }
    }


    public function skipToIndex(index:int):void
    {
      if (facade)
      {
        facade.doSkipToIndex(index);
      }
    }


    public function next():void
    {
      if (facade)
      {
        skipToIndex(currentIndex + 1);
      }
    }


    public function prev():void
    {
      if (facade)
      {
        var nextIndex:int = currentIndex - 1;
        if (nextIndex < 0)
        {
          nextIndex = 0;
        }
        skipToIndex(nextIndex);
      }
    }


    public function pause():void
    {
      if (facade)
      {
        facade.doPause();
      }
    }


    public function play():void
    {
      if (facade)
      {
        facade.doPlay();
      }
    }


    public function loadChannel(channelId:String, playImmediately:Boolean = false):void
    {
      if (facade)
      {
        facade.doLoadChannel(channelId, playImmediately);
      }
    }


    public function loadMedia(mediaId:String, playImmediately:Boolean = false, positionInMilliseconds:Number = 0):void
    {
      if (facade)
      {
        facade.doLoadMedia(mediaId, playImmediately, positionInMilliseconds);
      }
    }


    public function loadMediaWithAdConfigurationChannel(mediaId:String, playImmediately:Boolean = false, positionInMilliseconds:Number = 0, adConfigurationChannelId:String = null):void
    {
      if (facade)
      {
        facade.doLoadMediaWithAdConfigurationChannel(mediaId, playImmediately, positionInMilliseconds, adConfigurationChannelId);
      }
    }


    public function setMedia(mediaId:String, playImmediately:Boolean = false, positionInMilliseconds:Number = 0):void
    {
      if (facade)
      {
        facade.doSetMedia(mediaId, playImmediately, positionInMilliseconds);
      }
    }


    public function loadChannelAndSetMedia(channelId:String, mediaId:String, playImmediately:Boolean = false, positionInMilliseconds:Number = 0):void
    {
      if (facade)
      {
        facade.doLoadChannelAndSetMedia(channelId, mediaId, playImmediately, positionInMilliseconds);
      }
    }


    public function setChannel(channelId:String, mediaId:String = null, playImmediately:Boolean = false, positionInMilliseconds:Number = 0):void
    {
      if (facade)
      {
        facade.doSetChannel(channelId, mediaId, playImmediately, positionInMilliseconds);
      }
    }


    public function loadChannelList(channelListId:String, channelId:String = null, mediaId:String = null, playImmediately:Boolean = false, positionInMilliseconds:Number = 0):void
    {
      if (facade)
      {
        facade.doLoadChannelList(channelListId, channelId, mediaId, playImmediately, positionInMilliseconds);
      }
    }


    public function loadPlaylistByTags(commaSeparatedTags:String, orgId:String, sortOrderString:String):void
    {
      if (facade)
      {
        facade.doLoadPlaylistByTags(commaSeparatedTags, orgId, sortOrderString);
      }
    }


    public function setAd(position:String, type:String, params:String = null):void
    {
      if (facade)
      {
        facade.doSetAd(position, type, params);
      }
    }


    public function setAdFrequency(frequency:int):void
    {
      if (facade)
      {
        facade.doSetAdFrequency(frequency);
      }
    }


    //-------------------------------------------------------------
    //
    // Methods - Private
    //
    //-------------------------------------------------------------

    private function flexHack(value:Number):void
    {
    }


    private function updatePlayState(value:Boolean):void
    {
      if (value != _lastIsPlaying)
      {
        _lastIsPlaying = value;

        if (value && busyCheckTimer == 0)
        {
          busyCheckTimer = setInterval(checkIsBusy, 500);
        }
        else if (!value && busyCheckTimer != 0)
        {
          clearInterval(busyCheckTimer);
          busyCheckTimer = 0;
        }
      }
    }


    //-------------------------------------------------------------
    // Interval
    //-------------------------------------------------------------

    private function checkIsBusy():void
    {
      var isCurrentlyBusy:Boolean = (isPlaying && lastPositionInMilliseconds == positionInMilliseconds && !contentBlockingAdPlaying);

      if (_isBusy != isCurrentlyBusy)
      {
        _isBusy = isCurrentlyBusy;

        dispatchEvent(new DelveEvent(DelveEvent.EVENT_BUSY_STATE_CHANGED, {isBusy:_isBusy}));
      }
    }


    //-------------------------------------------------------------
    // Event Handlers
    //-------------------------------------------------------------

    private function addedToStageHandler(event:Event):void
    {
      if (!loader)
      {
        loader = new Loader();
        loader.addEventListener("applicationComplete", loader_applicationCompleteHandler, true, 0, true);
        loader.addEventListener(Event.COMPLETE, loader_completeHandler, true);
        addChild(loader);

        // Use this loaderContent to isolate Flex environments
        var loaderContext:LoaderContext = new LoaderContext(true, new ApplicationDomain(), SecurityDomain.currentDomain);

        loader.load(new URLRequest(SWF_URL), loaderContext);
      }
    }


    private function loader_applicationCompleteHandler(event:Event):void
    {
      loader.removeEventListener("applicationComplete", loader_applicationCompleteHandler, true);

      var delveSystemManager:Object = loader.content;

      if (delveSystemManager)
      {
        app = delveSystemManager.application;
        facade = app.getFacade();

        width = _width;
        height = _height;
        volume = _volume;

        if (facade)
        {
          facade.addEventListener(DelveEvent.EVENT_ERROR, delveControls_onErrorHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_AD_COMPLETE, delveControls_onAdCompleteHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_AD_LOAD, delveControls_onAdLoadHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_CHANNEL_COMPLETE, delveControls_onChannelCompleteHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_CHANNEL_LOAD, delveControls_onChannelLoadHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_CHANNEL_LIST_LOAD, delveControls_onChannelListLoadHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_MEDIA_COMPLETE, delveControls_onMediaCompleteHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_MEDIA_LOAD, delveControls_onMediaLoadHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_PLAYHEAD_UPDATE, delveControls_onPlayheadUpdateHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_PLAY_STATE_CHANGED, delveControls_onPlayStateChangedHandler, false, 0, true);
          facade.addEventListener(DelveEvent.EVENT_QUALITY_CHANGED, delveControls_onQualityChangedHandler, false, 0, true);

          dispatchEvent(new Event(Event.COMPLETE));
        }
      }
    }


    private function loader_completeHandler(event:Event):void
    {
      var delveSystemManager:Object = loader.content;

      if (delveSystemManager)
      {
        var app:Object = delveSystemManager.application;

        if (app is DisplayObjectContainer)
        {
          loader.removeEventListener(Event.COMPLETE, loader_completeHandler, true);

          if (config && config.flashVarsDict)
          {
            app.addParameters(config.flashVarsDict);
          }
        }
      }
    }


    private function delveControls_onErrorHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_ERROR, event.data));
    }


    private function delveControls_onAdCompleteHandler(event:Object):void
    {
      if (event.data)
      {
        switch (event.data.type)
        {
          case "Video":
          case "PostPlate":
            contentBlockingAdPlaying = false;
            break;
        }
      }

      dispatchEvent(new DelveEvent(DelveEvent.EVENT_AD_COMPLETE, event.data));
    }


    private function delveControls_onAdLoadHandler(event:Object):void
    {
      if (event.data)
      {
        switch (event.data.type)
        {
          case "Video":
          case "PostPlate":
            contentBlockingAdPlaying = true;
            break;
        }
      }

      dispatchEvent(new DelveEvent(DelveEvent.EVENT_AD_LOAD, event.data));
    }


    private function delveControls_onChannelCompleteHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_CHANNEL_COMPLETE, event.data));
    }


    private function delveControls_onChannelLoadHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_CHANNEL_LOAD, event.data));
    }


    private function delveControls_onChannelListLoadHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_CHANNEL_LIST_LOAD, event.data));
    }


    private function delveControls_onMediaCompleteHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_MEDIA_COMPLETE, event.data));
    }


    private function delveControls_onMediaLoadHandler(event:Object):void
    {
      _durationInMilliseconds = event.data ? event.data.durationInMilliseconds : 0;
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_MEDIA_LOAD, event.data));
    }


    private function delveControls_onPlayheadUpdateHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_PLAYHEAD_UPDATE, event.data));
    }


    private function delveControls_onPlayStateChangedHandler(event:Object):void
    {
      updatePlayState(event.data ? event.data.isPlaying : false);
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_PLAY_STATE_CHANGED, event.data));
    }


    private function delveControls_onQualityChangedHandler(event:Object):void
    {
      dispatchEvent(new DelveEvent(DelveEvent.EVENT_QUALITY_CHANGED, event.data));
    }
  }
}
