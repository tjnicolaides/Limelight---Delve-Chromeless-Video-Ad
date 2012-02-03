package
{
  import flash.events.Event;

  public class DelveEvent extends Event
  {
    //-------------------------------------------------------------
    //
    // Constants - Static - Public
    //
    //-------------------------------------------------------------

    /**
     * Errors that are being thrown by the player.  The messages may not always be consistent
     * between different revisions of the player.  This is to be used only for debugging.
     *
     * The properties of the event object have the following values:
     *    event.data.classType - The error class type
     *                           0 = general error
     *                           1 = search related error
     *                           2 = content related error
     *    event.data.message - The error message
     *
     *  @eventType onError
     */
    public static const EVENT_ERROR:String = "onError";

    /**
     * This event is dispatched when an Ad completes.
     *
     * The properties of the event object have the following values:
     *    event.data.type - Type of ad ("Video", "Overlay", "PostPlate")
     *
     *  @eventType onAdComplete
     */
    public static const EVENT_AD_COMPLETE:String = "onAdComplete";

    /**
     * This event is dispatched when an Ad is loaded.
     *
     * The properties of the event object have the following values:
     *    event.data.type - Type of ad ("Video", "Overlay", "PostPlate")
     *
     *  @eventType onAdLoad
     */
    public static const EVENT_AD_LOAD:String = "onAdLoad";


    /**
     * This event is dispatched when the channel has finished playing back.
     *
     * The properties of the event object have the following values:
     *    event.data.isBusy - If true, the player is busy (ie buffering).
     *
     *  @eventType onBusyStateChanged
     */
    public static const EVENT_BUSY_STATE_CHANGED:String = "onBusyStateChanged";

    /**
     * This event is dispatched when the channel has finished playing back.
     *
     * The properties of the event object have the following values:
     *    event.data.id
     *    event.data.title
     *
     *  @eventType onChannelComplete
     */
    public static const EVENT_CHANNEL_COMPLETE:String = "onChannelComplete";

    /**
     * This event is dispatched when the channel has loaded.
     *
     * The properties of the event object have the following values:
     *    event.data.id
     *    event.data.title
     *    event.data.mediaList - An array of Media
     *    event.data.mediaList.length - Number of items in the channel
     *    event.data.mediaList[].id
     *    event.data.mediaList[].title
     *    event.data.mediaList[].description
     *    event.data.mediaList[].thumbnailUrl
     *    event.data.mediaList[].durationInMilliseconds - The duration of the media in milliseconds.
     *    event.data.mediaList[].qualities[].name - The name of the quality: HD, High, Medium, Low, Lowest
     *    event.data.mediaList[].qualities[].bitrate - The actual bitrate of the media
     *
     *  @eventType onChannelLoad
     */
    public static const EVENT_CHANNEL_LOAD:String = "onChannelLoad";

    /**
     * This event is dispatched when the channel list has loaded.
     *
     * The properties of the event object have the following values:
     *    event.data.channelList - An array of abbreviated channel info
     *    event.data.channelList.length - Number of items
     *    event.data.channelList[].id
     *    event.data.channelList[].title
     *
     *  @eventType onChannelListLoad
     */
    public static const EVENT_CHANNEL_LIST_LOAD:String = "onChannelListLoad";

    /**
     * This event is dispatched when the media has completed playing back, including
     * all ads.
     *
     * The properties of the event object have the following values:
     *    event.data.id
     *    event.data.title
     *    event.data.description
     *    event.data.thumbnailUrl
     *    event.data.durationInMilliseconds - The duration of the media in milliseconds.
     *
     *  @eventType onMediaComplete
     */
    public static const EVENT_MEDIA_COMPLETE:String = "onMediaComplete";

    /**
     * This event is dispatched when the media has been loaded.
     *
     * The properties of the event object have the following values:
     *    event.data.id
     *    event.data.title
     *    event.data.description
     *    event.data.thumbnailUrl
     *    event.data.durationInMilliseconds - The duration of the media in milliseconds.
     *    event.data.qualities[].name - The name of the quality: HD, High, Medium, Low, Lowest
     *    event.data.qualities[].bitrate - The actual bitrate of the media
     *
     *  @eventType onMediaLoad
     */
    public static const EVENT_MEDIA_LOAD:String = "onMediaLoad";

    /**
     * This event is dispatched when the media's playhead changes.  This only gets dispatched
     * when the media is playing back.
     *
     * The properties of the event object have the following values:
     *    event.data.positionInMilliseconds - The current position (in milliseconds) of the media.
     *    event.data.durationInMilliseconds - The duration (in milliseconds) of the media.
     *
     *  @eventType onPlayheadUpdate
     */
    public static const EVENT_PLAYHEAD_UPDATE:String = "onPlayheadUpdate";

    /**
     * This event is dispatched when the play state changes.
     *
     * The properties of the event object have the following values:
     *    event.data.isPlaying - If true, the player is playing back.  If false, the player is
     *                           paused/stopped.
     *
     *  @eventType onPlayStateChanged
     */
    public static const EVENT_PLAY_STATE_CHANGED:String = "onPlayStateChanged";


    /**
     * This event is dispatched when the quality is initially set or changed (dynamically)
     *
     * The properties of the event object have the following values:
     *    event.data.name - The name of the quality: HD, High, Medium, Low, Lowest
     *    event.data.bitrate - The bitrate of the selected media
     *
     *  @eventType onQualityChanged
     */
    public static const EVENT_QUALITY_CHANGED:String = "onQualityChanged";


    //-------------------------------------------------------------
    //
    // Variables - Private
    //
    //-------------------------------------------------------------

    public var data:Object;


    //-------------------------------------------------------------
    //
    // Constructor
    //
    //-------------------------------------------------------------

    public function DelveEvent(type:String, data:Object)
    {
      super(type);
      this.data = data;
    }

  }
}
