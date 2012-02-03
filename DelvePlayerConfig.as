package
{
  import flash.utils.Dictionary;

  public class DelvePlayerConfig
  {
    //-------------------------------------------------------------
    //
    // Constructor
    //
    //-------------------------------------------------------------

    public function DelvePlayerConfig(flashVars:Object = null)
    {
      _flashVarsDict = new Dictionary();

      if (flashVars)
      {
        for (var key:String in flashVars)
        {
          if (key != "playerForm")
          {
            _flashVarsDict[key] = flashVars[key];
          }
        }
      }
    }

    //-------------------------------------------------------------
    //
    // Properties - Public
    //
    //-------------------------------------------------------------

    //-------------------------------------------------------------
    // autoplayNextClip
    //-------------------------------------------------------------

    /**
     * If true, the next clip will play back automatically after the clip finishes playing back.
     * If false, the next clip will not play back automatically.
     */
    public function set autoplayNextClip(value:Boolean):void
    {
      _flashVarsDict["autoplayNextClip"] = value;
    }


    //-------------------------------------------------------------
    // autoSkipNextClip
    //-------------------------------------------------------------

    /**
     * If true, after the clip finishes playing back, the next clip will be loaded up.
     * If false, after the clip finishes playing back, it will not move onto the next clip.
     */
    public function set autoSkipNextClip(value:Boolean):void
    {
      _flashVarsDict["autoSkipNextClip"] = value;
    }


    //-------------------------------------------------------------
    // channelId
    //-------------------------------------------------------------

    /**
     * The channel ID to load up at startup.
     */
    public function set channelId(value:String):void
    {
      _flashVarsDict["channelId"] = value;
    }


    //-------------------------------------------------------------
    // defaultQuality
    //-------------------------------------------------------------

    /**
     * The default quality to select.  Possible values are:
     *
     * Low
     * Medium
     * High
     * HD
     */
    public function set defaultQuality(value:String):void
    {
      _flashVarsDict["defaultQuality"] = value;
    }


    //-------------------------------------------------------------
    // flashVarsDict
    //-------------------------------------------------------------

    private var _flashVarsDict:Dictionary;

    public function get flashVarsDict():Dictionary
    {
      return _flashVarsDict;
    }


    //-------------------------------------------------------------
    // mediaId
    //-------------------------------------------------------------

    /**
     * The media ID to load up at startup.
     */
    public function set mediaId(value:String):void
    {
      _flashVarsDict["mediaId"] = value;
    }
  }
}
