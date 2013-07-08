package molyjam;

enum WidgetType
{
    // Testing
    TestToggle;

    // Visible to pilot
    Altitude;
    Pitch;
    Yaw;
    AirSpeed;
    Fuel; // 1, 2, 3, 4
    Direction;
    Fire; // 1, 2, 3, 4
    ToiletFault;

    // Changable by pilot AND passengers
    // Analog
    PitchChange;
    YawChange;
    Throttle;

    // Button
    FuelDump; // 1, 2, 3, 4
    EngineEnabled; // 1, 2, 3, 4
    FireExtinguisher; // 1, 2, 3, 4
    AutoPilot;
    AirBrakes;

    // Knob
    Oil;
    OilDesired;
    Hydro;
    HydroDesired;
    Flaps;
    FlapsDesired;

    // Changable only by pilot
    CallFlightAttendant;

    // Changable only by passengers
    ToiletFlush;
}

