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

function GetCenterCoord(MapCoordinates: TArray<TMapCoordinate>): TMapCoordinate;
function CoordinatesToFitZoom(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
function GooglePolylineToCoord(const Str: String; Precision: Integer): TArray<TMapCoordinate>;
function HaversineDistance(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;

implementation

// ===============================================================
function GetCenterCoord(MapCoordinates: TArray<TMapCoordinate>): TMapCoordinate;
var
  tLat, tLon: Double;
  i, j: Integer;

begin
  i := Length(MapCoordinates);
  tLat := 0;
  tLon := 0;

  for j := Low(MapCoordinates) to High(MapCoordinates) do
  begin
    tLat := tLat + MapCoordinates[j].Latitude;
    tLon := tLon + MapCoordinates[j].Longitude;
  end;

  Result.Latitude := tLat / i;
  Result.Longitude := tLon / i;
end;

// ===============================================================
function CoordinatesToFitZoom(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
var
  latDif, lngDif, latFrac, lngFrac, lngZoom, latZoom: Double;

  function LatRad(Lat: Double): Double;
  var
    sinValue, radX2: Double;
  begin
    sinValue := Sin(Lat * Pi / 180);
    radX2 := Ln((1 + sinValue) / (1 - sinValue)) / 2;
    Result := Max(Min(radX2, Pi), -Pi) / 2;
  end;

begin

  latDif := Abs(LatRad(LatitudeA) - LatRad(LatitudeB));
  lngDif := Abs(LongitudeA - LongitudeB);

  latFrac := latDif / Pi;
  lngFrac := lngDif / 360;

  lngZoom := Ln(1 / latFrac) / Ln(2);
  latZoom := Ln(1 / lngFrac) / Ln(2);

  Result := Min(lngZoom, latZoom);

end;

// ===============================================================
function GooglePolylineToCoord(const Str: String; Precision: Integer): TArray<TMapCoordinate>;
var
  Index, Shift, ByteResult, byte, factor: Integer;
  Lat, lng, latitude_change, longitude_change: Integer;
  coordinates: TArray<TMapCoordinate>;
begin
  index := 0;
  Lat := 0;
  lng := 0;
  factor := Round(Power(10, Precision));
  SetLength(coordinates, 0);

  while index < Length(Str) do
  begin

    Shift := 0;
    ByteResult := 0;

    repeat
      byte := Ord(Str[index + 1]) - 63;
      Inc(index);
      ByteResult := ByteResult or ((byte and $1F) shl Shift);
      Shift := Shift + 5;
    until byte < $20;

    latitude_change := IfThen((ByteResult and 1) <> 0, not(ByteResult shr 1), ByteResult shr 1);
    Shift := 0;
    ByteResult := 0;

    repeat
      byte := Ord(Str[index + 1]) - 63;
      Inc(index);
      ByteResult := ByteResult or ((byte and $1F) shl Shift);
      Shift := Shift + 5;
    until byte < $20;

    longitude_change := IfThen((ByteResult and 1) <> 0, not(ByteResult shr 1), ByteResult shr 1);

    Lat := Lat + latitude_change;
    lng := lng + longitude_change;

    SetLength(coordinates, Length(coordinates) + 1);
    coordinates[High(coordinates)] := TMapCoordinate.Create((Lat / factor), (lng / factor));
  end;

  Result := coordinates;
end;

// ===============================================================
function HaversineDistance(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
const
  earth_radius = 6371000; // In Meters

var
  phi_1, phi_2, delta_phi: Double;
  delta_lambda, z, c, dist: Double;

begin

  phi_1 := DegToRad(LatitudeA);
  phi_2 := DegToRad(LatitudeB);

  delta_phi := DegToRad(LatitudeB - LatitudeA);
  delta_lambda := DegToRad(LongitudeB - LongitudeA);

  z := Power(Sin(delta_phi / 2), 2) + cos(phi_1) * cos(phi_2) * Power(Sin(delta_lambda / 2.0), 2);
  c := 2 * ArcTan2(sqrt(z), sqrt(1 - z));

  Result := earth_radius * c;

end;

end.
