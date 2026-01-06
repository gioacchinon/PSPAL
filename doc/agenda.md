# PSPAL Code Refinement Agenda

## Priority 1: Critical Issues (High Impact)

---

## Priority 2: Medium Issues (Medium Impact)

---

## Priority 3: Minor Issues (Low Impact)

### 3.5 Update .gitignore and Documentation
- **Files:** .gitignore, README.md
- **Issue:** May need updates for new refinements
- **Action:** Review and update as needed
- **Status:** Not Started

---

## Implementations

### Terminal JSON fragment extensions
Windows Terminal is implementing JSON fragment extensions, I plan to update the installer to support this feature

### Design a better structure that facilitates compression

### Include an Unistall and a Packup scripts. add 'install from url' in the installer 

---

## Completed Tasks

### ~~3.1 Fix Typo: `Pluggins` → `Plugins~~
- **Files:** All references to folder
- **Issue:** Misspelled folder name throughout project
- **Action:** Rename folder and update all references
- **Status:** Fixed 

### ~~1.1 Fix Code Duplication in `pinning.ps1`~~
- **File:** [Pluggins/pinning.ps1](Pluggins/pinning.ps1)
- **Issue:** `Pin` function has 4+ near-identical branches (URL, File, Protocol, Exe)
- **Action:** Extract common logging/output logic into helper function
- **Status:** Fixed

### ~~1.3 Improve Error Handling in Core Functions~~
- **Files:** [Pluggins/fuzzysearch.ps1](Pluggins/fuzzysearch.ps1), [Pluggins/browsing.ps1](Pluggins/browsing.ps1), [Pluggins/notes.ps1](Pluggins/notes.ps1)
- **Issue:** Missing try-catch blocks and input validation
- **Action:** Add comprehensive error handling to all plugin functions
- **Status:** done

### ~~2.2 Clean Up Global Variable Scope~~
- **File:** [PROFILE.ps1](PROFILE.ps1#L1-L10)
- **Issue:** `$charIndex` and other globals could conflict with user scripts
- **Action:** Prefix global variables with unique namespace (e.g., `$PSPal_charIndex`)
- **Status:** done

### ~~2.1 Simplify Notes JSON Array Handling~~
- **File:** [Pluggins/notes.ps1](Pluggins/notes.ps1#L30-L40)
- **Issue:** Doll placeholder hack is confusing and complicates logic
- **Action:** Refactor array unrolling logic or use better data structure
- **Status:** feature deprecated

### ~~2.3 Improve Parameter Handling in `Get-Note`~~
- **File:** [Pluggins/notes.ps1](Pluggins/notes.ps1#L69-L82)
- **Issue:** Function has 6 optional parameters, could be cleaner with hashtable
- **Action:** Refactor to accept hashtable for filter criteria
- **Status:** feature deprecated

### ~~3.3 Add Comment-Based Help to Functions~~
- **Files:** All plugin files
- **Issue:** Missing parameter descriptions and examples
- **Action:** Add .SYNOPSIS, .DESCRIPTION, .EXAMPLE blocks
- **Status:** Completed
