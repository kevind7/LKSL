{
  This unit contains the defintions for two Event Types and two Event Listener Types.

  Read the annotations associated with each Class and Method to see what's going on.
  It's far simpler than it may at first appear!
}
unit LKSL.Demos.EEBasicTestEvents;

interface

uses
  System.Classes, System.SysUtils, System.Types,
  LKSL.Events.Base;

type
  { Forward Declarations }
  // Event Types
  TEventGenerateCircle = class;
  TEventCircleGenerated = class;
  // Event Listener Types
  TEventListenerGenerateCircle = class;
  TEventListenerCircleGenerated = class;

  { Record Types }
  TEdge = record
    Vertice1,
    Vertice2: TPointF;
  end;

  { Array Types }
  TEdges = Array of TEdge;

  { Callback Types }
  TEventGenerateCircleCallback = procedure(const AGenerateCircleEvent: TEventGenerateCircle) of object;
  TEventCircleGeneratedCallback = procedure(const ACircleGeneratedEevnt: TEventCircleGenerated) of object;

  {
    TEventGenerateCircle
      - This Event Type provides relevant information for any Listener to use in the generation of a
        "circle". The number of Segments specified will actually dictate the shape
        (3 = triangle, 4 = diamond etc)
  }
  TEventGenerateCircle = class(TLKEvent)
  private
    FPosition: TPointF;
    FRadius: Double;
    FSegments: Integer;
  protected
    procedure Clone(const AFromEvent: TLKEvent); override;
  public
    class function GetTypeGUID: String; override;
    constructor Create(const APosition: TPointF; const ARadius: Double; const ASegments: Integer); reintroduce;

    { TLKStreamable Overrides Begin }
    class procedure DeleteFromStream(const AStream: TStream); override;
    procedure ReadFromStream(const AStream: TStream); override;
    procedure InsertIntoStream(const AStream: TStream); override;
    procedure WriteToStream(const AStream: TStream); override;
    { TLKStreamable Overrides End }

    property Position: TPointF read FPosition;
    property Radius: Double read FRadius;
    property Segments: Integer read FSegments;
  end;

  {
    TEventCircleGenerated
      - This Event Type is dispatched once a "circle" has been generated.
      - It provides the "Edge Data" (an Array of paired Vertices between which lines are rendered)
      - It also provides the number of seconds taken to generate the circle
  }
  TEventCircleGenerated = class(TLKEvent)
  private
    FGenerationTime: Double;
    FEdges: TEdges;
  protected
    procedure Clone(const AFromEvent: TLKEvent); override;
  public
    class function GetTypeGUID: String; override;
    constructor Create(const AEdges: TEdges; const AGenerationTime: Double); reintroduce;

   { TLKStreamable Overrides Begin }
    class procedure DeleteFromStream(const AStream: TStream); override;
    procedure ReadFromStream(const AStream: TStream); override;
    procedure InsertIntoStream(const AStream: TStream); override;
    procedure WriteToStream(const AStream: TStream); override;
    { TLKStreamable Overrides End }

    property GenerationTime: Double read FGenerationTime;
    property Edges: TEdges read FEdges;
  end;

  {
    TEventListenerGenerateCircle
      - This Listener Type listens SPECIFICALLY for "TEventGenerateCircle" Events
      - When a "TEventGenerateCircle" is received by this Listener, it excutes the "OnGenerateCircle"
        Callback Method, which one would hope is coded to generate a Circle, and dispatch a
        "TEventCircleGenerated" Event containing the results.
  }
  TEventListenerGenerateCircle = class(TLKEventListener)
  private
    FOnGenerateCircle: TEventGenerateCircleCallback;
    function GetOnGenerateCircle: TEventGenerateCircleCallback;
    procedure SetOnGenerateCircle(const AOnGenerateCircle: TEventGenerateCircleCallback);
  protected
    function GetDefaultNewestEventOnly: Boolean; override;
  public
    function GetEventType: TLKEventType; override;
    procedure EventCall(const AEvent: TLKEvent); override;
    property OnGenerateCircle: TEventGenerateCircleCallback read GetOnGenerateCircle write SetOnGenerateCircle;
  end;

  {
    TEventListenerCircleGenerated
      - This Listner Type listens SPECIFICALLY for "TEventCircleGenerated" Events
      - When a "TEventCircleGenerated" is received, it executes the "OnCircleGenerated" Callback Method,
        which one would hope is coded to RENDER the Edge Data onto a Form.
      - Since this Listener is being executed on the UI thread, it is STRONGLY recommended you set
        "CallUIThread" to "True" on instances of this Listener Type, to Synchronize the call and prevent
        failure.
  }
  TEventListenerCircleGenerated = class(TLKEventListener)
  private
    FOnCircleGenerated: TEventCircleGeneratedCallback;
    function GetOnCircleGenerated: TEventCircleGeneratedCallback;
    procedure SetOnCircleGenerated(const AOnCircleGenerated: TEventCircleGeneratedCallback);
  protected
    function GetDefaultNewestEventOnly: Boolean; override;
  public
    function GetEventType: TLKEventType; override;
    procedure EventCall(const AEvent: TLKEvent); override;
    property OnCircleGenerated: TEventCircleGeneratedCallback read GetOnCircleGenerated write SetOnCircleGenerated;
  end;

implementation

uses
  LKSL.Streams.System, LKSL.Streams.Types;

// Internal Stream Delete Methods
procedure StreamDeleteTEdges(const AStream: TStream);
var
  LCount, I: Integer;
begin
  I := AStream.Position; // Keep a reference to the current Position
  LCount := StreamReadInteger(AStream); // Get the Edge Count from the Stream
  AStream.Position := I; // Reset our Position back to the beginning of the block
  StreamDeleteInteger(AStream); // Delete the Edge Count from the Stream
  for I := 0 to LCount - 1 do // Iterate the number of Edges in the Array
    StreamClearSpace(AStream, SizeOf(TEdge)); // Delete the Edge from the Stream
end;

// Internal Stream Insert Methods
procedure StreamInsertTEdges(const AStream: TStream; const AEdges: TEdges);
var
  I: Integer;
begin
  StreamInsertInteger(AStream, Length(AEdges)); // Insert the Edge Count into the Stream
  for I := Low(AEdges) to High(AEdges) do // Iterate the Edges
  begin
    StreamMakeSpace(AStream, SizeOf(TEdge)); // Make room in the Stream for an Edge
    AStream.Write(AEdges[I], SizeOf(TEdge)); // Insert the Edge into the Array
  end;
end;

// Internal Stream Read Methods
function StreamReadTEdges(const AStream: TStream): TEdges;
var
  LCount, I: Integer;
begin
  LCount := StreamReadInteger(AStream); // Read the Edge Count from the Stream
  SetLength(Result, LCount); // Ensure the Array is large enough to hold all the Edges
  for I := 0 to LCount - 1 do // Iterate the number of Edges
  begin
    AStream.Read(Result[I], SizeOf(TEdge)); // Read this Edge into the Array
  end;
end;

// Internal Stream Write Methods
procedure StreamWriteTEdges(const AStream: TStream; const AEdges: TEdges);
var
  I: Integer;
begin
  StreamWriteInteger(AStream, Length(AEdges)); // Write the Edge Count into the Stream
  for I := Low(AEdges) to High(AEdges) do // Iterate the Edges
    AStream.Write(AEdges[I], SizeOf(TEdge)); // Write the Edge into the Array
end;

{ TEventGenerateCircle }

procedure TEventGenerateCircle.Clone(const AFromEvent: TLKEvent);
begin
  // It is absolutely CRITICAL that you don't forget to set Cloned Instance Values to match the
  // "AFromEvent" (which is the ORIGINAL Event Instance)
  inherited;
  FPosition := TEventGenerateCircle(AFromEvent).FPosition;
  FRadius := TEventGenerateCircle(AFromEvent).FRadius;
  FSegments := TEventGenerateCircle(AFromEvent).FSegments;
end;

constructor TEventGenerateCircle.Create(const APosition: TPointF; const ARadius: Double; const ASegments: Integer);
begin
  // We populate the Event Data using the Constructor because this enables us to fully prepare the Event
  // with a single line of code.
  inherited Create;
  FPosition := APosition;
  FRadius := ARadius;
  FSegments := ASegments;
end;

class procedure TEventGenerateCircle.DeleteFromStream(const AStream: TStream);
begin
  inherited;
  StreamDeleteTPointF(AStream); // Delete FPosition
  StreamDeleteDouble(AStream); // Delete FRadius
  StreamDeleteInteger(AStream); // Delete FSegments
end;

class function TEventGenerateCircle.GetTypeGUID: String;
begin
  // This GUID String uniquely identifies THIS Event Type.
  // Technically, you COULD use ANY String value, but GUID Strings are recommended to ensure they are
  // ALWAYS unique!
  Result := '{16C435CF-22D2-44C3-B401-7BCACB4B4430}';
end;

procedure TEventGenerateCircle.InsertIntoStream(const AStream: TStream);
begin
  Lock;
  inherited;
  StreamInsertTPointF(AStream, FPosition); // Insert FPosition
  StreamInsertDouble(AStream, FRadius); // Insert FRadius
  StreamInsertInteger(AStream, FSegments); // Insert FSegments
  Unlock;
end;

procedure TEventGenerateCircle.ReadFromStream(const AStream: TStream);
begin
  Lock;
  inherited;
  StreamReadTPointF(AStream); // Read FPosition
  StreamReadDouble(AStream); // Read FRadius
  StreamReadInteger(AStream); // Read FSegments
  Unlock;
end;

procedure TEventGenerateCircle.WriteToStream(const AStream: TStream);
begin
  Lock;
  inherited;
  StreamWriteTPointF(AStream, FPosition); // Write FPosition
  StreamWriteDouble(AStream, FRadius); // Write FRadius
  StreamWriteInteger(AStream, FSegments); // Write FSegments
  Unlock;
end;

{ TEventCircleGenerated }

procedure TEventCircleGenerated.Clone(const AFromEvent: TLKEvent);
begin
  inherited;
  FEdges := TEventCircleGenerated(AFromEvent).FEdges;
end;

constructor TEventCircleGenerated.Create(const AEdges: TEdges; const AGenerationTime: Double);
begin
  inherited Create;
  FEdges := AEdges;
  FGenerationTime := AGenerationTime;
end;

class procedure TEventCircleGenerated.DeleteFromStream(const AStream: TStream);
begin
  inherited;
  StreamDeleteDouble(AStream); // Delete FGenerationTime
  StreamDeleteTEdges(AStream); // Delete FEdges
end;

class function TEventCircleGenerated.GetTypeGUID: String;
begin
  Result := '{5AF9C38C-4308-47AE-90D8-502B7710BD3D}';
end;

procedure TEventCircleGenerated.InsertIntoStream(const AStream: TStream);
begin
  Lock;
  inherited;
  StreamInsertDouble(AStream, FGenerationTime); // Insert FGenerationTime
  StreamInsertTEdges(AStream, FEdges); // Insert FEdges
  Unlock;
end;

procedure TEventCircleGenerated.ReadFromStream(const AStream: TStream);
begin
  Lock;
  inherited;
  FGenerationTime := StreamReadDouble(AStream); // Read FGenerationTime
  FEdges := StreamReadTEdges(AStream); // Read FEdges;
  Unlock;
end;

procedure TEventCircleGenerated.WriteToStream(const AStream: TStream);
begin
  Lock;
  inherited;
  StreamWriteDouble(AStream, FGenerationTime); // Write FGenerationTime
  StreamWriteTEdges(AStream, FEdges); // Write FEdges
  Unlock;
end;

{ TEventListenerGenerateCircle }

procedure TEventListenerGenerateCircle.EventCall(const AEvent: TLKEvent);
begin
  inherited;
  Lock; // We engage the Lock to prevent anything changing the value of "FOnGenerateCircle"
  if Assigned(FOnGenerateCircle) then
    FOnGenerateCircle(TEventGenerateCircle(AEvent));
  Unlock; // Must not forget to UNLOCK when we're done.
end;

function TEventListenerGenerateCircle.GetDefaultNewestEventOnly: Boolean;
begin
  // We only care about the LATEST instruction to generate a "Circle"
  Result := True;
end;

function TEventListenerGenerateCircle.GetEventType: TLKEventType;
begin
  // We MUST return the exact Event Type this Listener is intended to listen for.
  Result := TEventGenerateCircle;
end;

function TEventListenerGenerateCircle.GetOnGenerateCircle: TEventGenerateCircleCallback;
begin
  Lock;
  Result := FOnGenerateCircle;
  Unlock;
end;

procedure TEventListenerGenerateCircle.SetOnGenerateCircle(const AOnGenerateCircle: TEventGenerateCircleCallback);
begin
  Lock;
  FOnGenerateCircle := AOnGenerateCircle;
  Unlock;
end;

{ TEventListenerCircleGenerated }

procedure TEventListenerCircleGenerated.EventCall(const AEvent: TLKEvent);
begin
  inherited;
  Lock;
  if Assigned(FOnCircleGenerated) then
    FOnCircleGenerated(TEventCircleGenerated(AEvent));
  Unlock;
end;

function TEventListenerCircleGenerated.GetDefaultNewestEventOnly: Boolean;
begin
  // We don't want to draw over the NEWEST "circle" with older ones!
  Result := True;
end;

function TEventListenerCircleGenerated.GetEventType: TLKEventType;
begin
  Result := TEventCircleGenerated;
end;

function TEventListenerCircleGenerated.GetOnCircleGenerated: TEventCircleGeneratedCallback;
begin
  Lock;
  Result := FOnCircleGenerated;
  Unlock;
end;

procedure TEventListenerCircleGenerated.SetOnCircleGenerated(const AOnCircleGenerated: TEventCircleGeneratedCallback);
begin
  Lock;
  FOnCircleGenerated := AOnCircleGenerated;
  Unlock;
end;

end.
