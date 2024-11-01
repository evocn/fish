// Dayne
// Schedule
// October 2024

// Entities check their behaviors against schedules, which 

Plan :: enum #complete {
    NEUTRAL;
    SLEEP;
    EAT;
}

Schedule :: struct {
    hours : [24] Plan;
}

get_current_plan :: (schedule: Schedule) -> Plan {
    hour := time().hour;
    return schedule.hours[hour];
}
