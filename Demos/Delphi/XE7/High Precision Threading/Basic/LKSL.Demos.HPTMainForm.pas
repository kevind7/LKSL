unit LKSL.Demos.HPTMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  LKSL.Demos.HPTTestThread, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Layouts;

type
  TfrmMain = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    nbTickRateLimit: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    nbAverageOver: TNumberBox;
    Label4: TLabel;
    Label5: TLabel;
    lblTickCount: TLabel;
    Label6: TLabel;
    lblDelta: TLabel;
    Label7: TLabel;
    lblStartTime: TLabel;
    Label8: TLabel;
    lblTickRateInstant: TLabel;
    Label9: TLabel;
    lblAverageTickRate: TLabel;
    lblAverageBig: TLabel;
    ScaledLayout1: TScaledLayout;
    Label10: TLabel;
    cbYield: TCheckBox;
    Label11: TLabel;
    lblNextTickTime: TLabel;
    Label12: TLabel;
    nbTickRateDesired: TNumberBox;
    Label13: TLabel;
    Label14: TLabel;
    lblExtraTicks: TLabel;
    Label15: TLabel;
    lblExtraTicksAverage: TLabel;
    Label16: TLabel;
    lblExtraTime: TLabel;
    Label18: TLabel;
    lblExtraTimeAverage: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure nbTickRateLimitChange(Sender: TObject);
    procedure nbAverageOverChange(Sender: TObject);
    procedure cbYieldChange(Sender: TObject);
    procedure nbTickRateDesiredChange(Sender: TObject);
  private
    FTicks: Int64;
    procedure TestTick(const ADelta, AStartTime, ATickRate, ATickRateAverage, ATickRateAverageOver, ATickRateLimit, ANextTick, AExtraTicks, AExtraTicksAverage, AExtraTime, AExtraTimeAverage: Double);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.cbYieldChange(Sender: TObject);
begin
  TestThread.YieldAccumulatedTime := cbYield.IsChecked;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  TestThread.OnTick := TestTick;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  TestThread.OnTick := nil;
end;

procedure TfrmMain.nbAverageOverChange(Sender: TObject);
begin
  TestThread.TickRateAverageOver := nbAverageOver.Value;
end;

procedure TfrmMain.nbTickRateDesiredChange(Sender: TObject);
begin
  TestThread.TickRateDesired := nbTickRateDesired.Value;
end;

procedure TfrmMain.nbTickRateLimitChange(Sender: TObject);
begin
  TestThread.TickRateLimit := nbTickRateLimit.Value;
  FTicks := 0;
end;

procedure TfrmMain.TestTick(const ADelta, AStartTime, ATickRate, ATickRateAverage, ATickRateAverageOver, ATickRateLimit, ANextTick, AExtraTicks, AExtraTicksAverage, AExtraTime, AExtraTimeAverage: Double);
var
  LTickRatePercent: Double;
begin
  Inc(FTicks);
  lblTickCount.Text := Format('%d', [FTicks]);
  lblDelta.Text := FormatFloat('0.00000000', ADelta) + ' seconds';
  lblStartTime.Text := FormatFloat('0.00000000', AStartTime);
  lblTickRateInstant.Text := FormatFloat('0.00000000', ATickRate) + ' per second';
  lblAverageTickRate.Text := FormatFloat('0.00000000', ATickRateAverage) + ' per second';
  lblNextTickTime.Text := FormatFloat('0.00000000', ANextTick);
  lblExtraTicks.Text := FormatFloat('0.00000000', AExtraTicks) + ' per second (negative = dropped ticks)';
  lblExtraTicksAverage.Text := FormatFloat('0.00000000', AExtraTicksAverage) + ' per second (negative = dropped ticks)';
  lblExtraTime.Text := FormatFloat('0.00000000', AExtraTime) + ' seconds (negative = lost time)';
  lblExtraTimeAverage.Text := FormatFloat('0.00000000', AExtraTimeAverage) + ' seconds (negative = lost time)';

  lblAverageBig.Text := FormatFloat('0.00', ATickRateAverage);
  if nbTickRateLimit.Value = 0.00 then
    lblAverageBig.TextSettings.FontColor := TAlphaColors.Black
  else
  begin
    if ATickRateAverage >= nbTickRateLimit.Value then
      lblAverageBig.TextSettings.FontColor := TAlphaColorF.Create(0.00, 1.00, 0.00, 1.00).ToAlphaColor
    else
    begin
      LTickRatePercent := (ATickRateAverage / nbTickRateLimit.Value) * 100;
      lblAverageBig.TextSettings.FontColor := TAlphaColorF.Create(1.00 * (1 - LTickRatePercent / 100), 1.00 * (LTickRatePercent / 100), 0.00, 1.00).ToAlphaColor;
    end;
  end;
end;

end.
