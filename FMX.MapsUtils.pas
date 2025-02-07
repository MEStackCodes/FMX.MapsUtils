unit FMX.MapsUtils;

{
  * ===========================================================================
  * FMX.MapsUtils -- Conversion Functions
  * Copyright (c) 2025 - MEStackCodes
  * ---------------------------------------------------------------------------
  * Distributed under the MIT software license.
  * ===========================================================================
}

interface

uses System.SysUtils, System.Math, FMX.Maps;

function CoordinatesToFitZoom(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
function GetCenterCoord(MapCoordinates: TArray<TMapCoordinate>): TMapCoordinate;
function GooglePolylineToCoord(const Str: String; Precision: Integer): TArray<TMapCoordinate>;
function HaversineDistance(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;

implementation

// ===============================================================
function GetCenterCoord(MapCoordinates: TArray<TMapCoordinate>): TMapCoordinate;
var
  TLat, TLon: Double;
  I, J: Integer;

begin
  I := Length(MapCoordinates);
  TLat := 0;
  TLon := 0;

  for J := Low(MapCoordinates) to High(MapCoordinates) do
  begin
    TLat := TLat + MapCoordinates[J].Latitude;
    TLon := TLon + MapCoordinates[J].Longitude;
  end;

  Result.Latitude := TLat / I;
  Result.Longitude := TLon / I;
end;

// ===============================================================
function CoordinatesToFitZoom(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
var
  LatDif, LngDif, LatFrac, LngFrac, LngZoom, LatZoom: Double;

  function LatRad(Lat: Double): Double;
  var
    SinValue, RadX2: Double;
  begin
    SinValue := Sin(Lat * Pi / 180);
    RadX2 := Ln((1 + SinValue) / (1 - SinValue)) / 2;
    Result := Max(Min(RadX2, Pi), -Pi) / 2;
  end;

begin

  LatDif := Abs(LatRad(LatitudeA) - LatRad(LatitudeB));
  LngDif := Abs(LongitudeA - LongitudeB);

  LatFrac := LatDif / Pi;
  LngFrac := LngDif / 360;

  LngZoom := Ln(1 / LatFrac) / Ln(2);
  LatZoom := Ln(1 / LngFrac) / Ln(2);

  Result := Min(LngZoom, LatZoom);

end;

// ===============================================================
function GooglePolylineToCoord(const Str: String; Precision: Integer): TArray<TMapCoordinate>;
var
  Index, Shift, ByteResult, Byte, Factor: Integer;
  Lat, Lng, LatitudeChange, LongitudeChange: Integer;
  Coordinates: TArray<TMapCoordinate>;

begin

  index := 0;
  Lat := 0;
  Lng := 0;
  Factor := Round(Power(10, Precision));
  SetLength(Coordinates, 0);

  while index < Length(Str) do
  begin

    Shift := 0;
    ByteResult := 0;

    repeat
      Byte := Ord(Str[index + 1]) - 63;
      Inc(index);
      ByteResult := ByteResult or ((Byte and $1F) shl Shift);
      Shift := Shift + 5;
    until Byte < $20;

    LatitudeChange := IfThen((ByteResult and 1) <> 0, not(ByteResult shr 1), ByteResult shr 1);
    Shift := 0;
    ByteResult := 0;

    repeat
      Byte := Ord(Str[index + 1]) - 63;
      Inc(index);
      ByteResult := ByteResult or ((Byte and $1F) shl Shift);
      Shift := Shift + 5;
    until Byte < $20;

    LongitudeChange := IfThen((ByteResult and 1) <> 0, not(ByteResult shr 1), ByteResult shr 1);

    Lat := Lat + LatitudeChange;
    Lng := Lng + LongitudeChange;

    SetLength(Coordinates, Length(Coordinates) + 1);
    Coordinates[High(Coordinates)] := TMapCoordinate.Create((Lat / Factor), (Lng / Factor));
  end;

  Result := Coordinates;
end;

// ===============================================================
function HaversineDistance(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;

const
  Earth_Radius = 6371000; // In Meters

var
  Phi1, Phi2, DeltaPhi: Double;
  DeltaLambda, Z, C, Dist: Double;

begin

  Phi1 := DegToRad(LatitudeA);
  Phi2 := DegToRad(LatitudeB);

  DeltaPhi := DegToRad(LatitudeB - LatitudeA);
  DeltaLambda := DegToRad(LongitudeB - LongitudeA);

  Z := Power(Sin(DeltaPhi / 2), 2) + cos(Phi1) * cos(Phi2) * Power(Sin(DeltaLambda / 2.0), 2);
  C := 2 * ArcTan2(sqrt(Z), sqrt(1 - Z));

  Result := Earth_Radius * C;

end;

end.
