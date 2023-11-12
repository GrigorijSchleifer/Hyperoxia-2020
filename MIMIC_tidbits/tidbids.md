### MIMIC III vs. MIMIC IV 

* ward_id for the physical bed location only in MIMIC III, not in MIMIC IV
* MIMIC III ends in 2012, MIMIC IV in 2019
* MIMIC III doesnt have mimic_hosp

### MIMIC III AND MIMIC IV 
* 2008 - 2012 same admissions
* subject_id belongs always to the same person
* inputevents is a table for i.v. medications

### MIMIC III
* published in 2015
* 2001 - 2008: CareView
* 2008 - 2012: MetaVision iMDSoft (Israel) 
* __DOD_SSN__ death up to 90 days in the future for Metavision patients. It contains dates of death up to 4 years in the future for CareVue patients.
* mimic_icu is the core of MIMIC III

### MIMIC IV

* released in 2020
* 2008 - 2019
* Dates of birth which occur in the present time are not true dates of birth
* four mudules mimic_core, mimic_icu (most data?), mimic_ed, mimic_cxr
* mimic_hosp is source from the hospital EHR and contains out of hospital information as well
* to retrieve diagnoses for a patient - drgcodes (very general) and diagnoses_icd (very detailed)
* dates of birth which occur before the year 1900 occur if the patient is older than 89
