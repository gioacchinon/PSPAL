<#
.SYNOPSIS
    Displays the school timetable

.DESCRIPTION
    Shows the weekly school schedule with teacher names and subject assignments for each class period.
    This plugin loads the timetable data and displays it formatted by day and class period.

.EXAMPLE
    .\schoolttable.ps1
    Displays the complete school timetable

.NOTES
    The timetable is hardcoded for a specific school schedule and uses teacher/subject lookup tables.
#>

$Timetable = [ordered]@{
    Monday    = @(@(0, 4), @(0, 0), @(1, 0), @(1, 1), @(4, 0))
    Tuesday   = @(@(6, 0), @(2, 1), @(0, 4), @(0, 1), @(1, 0))
    Wednesday = @(@(5, 1), @(6, 0), @(3, 0), @(7, 0), @(2, 1))
    Thursday  = @(@(3, 1), @(3, 1), @(4, 0), @(1, 0), @(1, 1))
    Friday    = @(@(0, 0), @(5, 0), @(3, 0), @(3, 0), @(2, 1))
    Saturday  = @(@(0, 2), @(0, 2), @(1, 1), @(1, 1), @(4, 0))
}

$SubjTable = @(
    [PSCustomObject]@{ Teacher = "Schirru N.";	Subjects = @("Letteratura Latina", "Grammatica Latina", "Lettere", "Grammatica Italiana", "D. Commedia")},
    [PSCustomObject]@{ Teacher = "Schirru F.";	Subjects = @("Matematica", "Fisica")},
	[PSCustomObject]@{ Teacher = "Pingiori";	Subjects = @("Biologia", "Chimica")},
    [PSCustomObject]@{ Teacher = "Ballai S.";	Subjects = @("Storia", "Philosophia")},
    [PSCustomObject]@{ Teacher = "Zucca I.";	Subjects = @("Inglese")},
    [PSCustomObject]@{ Teacher = "Congiu M.";	Subjects = @("Arte", "Disegno Tecnico")},
    [PSCustomObject]@{ Teacher = "Puzzu G.L.";	Subjects = @("Scienze Motorie")},
	[PSCustomObject]@{ Teacher = "Angioi R.";	Subjects = @("Scienze Religiose")}
)

function Resolve-TimetableEntry($ref) {
    $teacherIndex = $ref[0]
    $subjectIndex = $ref[1]
    $teacher = $SubjTable[$teacherIndex].Teacher
    $subject = $SubjTable[$teacherIndex].Subjects[$subjectIndex]
    return [PSCustomObject]@{
        Subject = $subject
        Teacher = $teacher
    }
}

foreach ($day in $Timetable.Keys) {
    Write-Host "`n$day"
    for ($i = 0; $i -lt $Timetable[$day].Count; $i++) {
        $entry = Resolve-TimetableEntry $Timetable[$day][$i]
        $hour = $i
        Write-Host "  $hour : $($entry.Subject) → $($entry.Teacher)"
    }
}