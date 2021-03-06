{
  LaKraven Studios Standard Library [LKSL]
  Copyright (c) 2014, LaKraven Studios Ltd, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/LKSL

  License:
    - You may use this library as you see fit, including use within commercial applications.
    - You may modify this library to suit your needs, without the requirement of distributing
      modified versions.
    - You may redistribute this library (in part or whole) individually, or as part of any
      other works.
    - You must NOT charge a fee for the distribution of this library (compiled or in its
      source form). It MUST be distributed freely.
    - This license and the surrounding comment block MUST remain in place on all copies and
      modified versions of this source code.
    - Modified versions of this source MUST be clearly marked, including the name of the
      person(s) and/or organization(s) responsible for the changes, and a SEPARATE "changelog"
      detailing all additions/deletions/modifications made.

  Disclaimer:
    - Your use of this source constitutes your understanding and acceptance of this
      disclaimer.
    - LaKraven Studios Ltd and its employees (including but not limited to directors,
      programmers and clerical staff) cannot be held liable for your use of this source
      code. This includes any losses and/or damages resulting from your use of this source
      code, be they physical, financial, or psychological.
    - There is no warranty or guarantee (implicit or otherwise) provided with this source
      code. It is provided on an "AS-IS" basis.

  Donations:
    - While not mandatory, contributions are always appreciated. They help keep the coffee
      flowing during the long hours invested in this and all other Open Source projects we
      produce.
    - Donations can be made via PayPal to PayPal [at] LaKraven (dot) Com
                                          ^  Garbled to prevent spam!  ^
}
unit LKSL.Common.Types;

{
  About this unit:
    - This unit provides fundamental abstract base types used throughout the LKSL

  Changelog (latest changes first):
    3rd September 2014:
      - Prepared for Release
}

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs;

type
  { Forward Declarations }
  TLKPersistent = class;

  { Exception Types }
  ELKException = class(Exception);

  {
    TLKPersistent
      - Provides a "Critical Section" (or "Lock") to make members "Thread-Safe"
  }
  TLKPersistent = class(TPersistent)
  private
    FLock: TCriticalSection;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
  end;

implementation

{ TLKPersistent }

constructor TLKPersistent.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TLKPersistent.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TLKPersistent.Lock;
begin
  FLock.Acquire;
end;

procedure TLKPersistent.Unlock;
begin
  FLock.Release;
end;

end.
