/*QUERY FOR ADMISSION DATA*/
-- Where clause demonstrate how data is searched for
-- DRG code 175 and 176 are used as an inclusion criteria, which represents patients with PE
-- DRG codes 134.1, 134.2, 134.3 and 134.4 also represents PE. However, these are the APR-DRG codes, and these codes sometimes pulled patients with
-- "COMPLICATED PEPTIC ULCER" or "GASTROINTESTINAL HEMORRHAGE WITHOUT COMPLICATIONS, COMORBIDITIES". These patients were therefore excluded
-- ICD9 code 415.* is for pulmonary embolism
-- Additionally, a right join with the Note Events table was utilized with a where clause looking for CT scan notes.
-- right join with the Note Events table was utilized with a where clause looking for CT scan notes.

SELECT  DISTINCT PatDim.SUBJECT_ID 
       ,Admissions.HADM_ID
       ,PatDim.GENDER
       ,PatDim.DOB
       ,PatDim.DOD
       ,PatDim.DOD_HOSP
       ,PatDim.DOD_SSN
       ,PatDim.EXPIRE_FLAG
       ,Admissions.DIAGNOSIS
       ,Admissions.LANGUAGE
       ,Admissions.ETHNICITY
       ,Admissions.MARITAL_STATUS
       ,Admissions.RELIGION
       ,Admissions.INSURANCE
       ,Admissions.ADMITTIME
       ,Admissions.DISCHTIME
       ,Admissions.DEATHTIME
       ,Admissions.ADMISSION_LOCATION
       ,Admissions.DISCHARGE_LOCATION
  FROM `physionet-data.mimiciii_clinical.admissions` AS Admissions

left join `physionet-data.mimiciii_clinical.diagnoses_icd` AS Dx on
Admissions.HADM_ID = Dx.HADM_ID

left join `physionet-data.mimiciii_clinical.drgcodes` AS DrgDim on
Admissions.HADM_ID = DrgDim.HADM_ID

left join `physionet-data.mimiciii_clinical.patients` AS PatDim on
Admissions.SUBJECT_ID = PatDim.SUBJECT_ID

right join (select DISTINCT * from `physionet-data.mimiciii_derived.noteevents_metadata` 

where DESCRIPTION IN
    ('CHEST CTA WITH CONTRAST',
    'CT CHEST AND ABDOMEN W/O CONTRAST',
    'CT CHEST W&W/O C',
    'CT CHEST W/CONT+RECONSTRUCTION',
    'CT CHEST W/CONTRAST',
    'CT CHEST W/CONTRAST W/ONC TABLE',
    'CT CHEST W/O CONTRAST',
    'CT CHEST W/O CONTRAST W/ONC TABLES',
    'CT STEREOTAXIS CHEST W/ CONTRAST',
    'CTA CHEST W&W/O C &RECONS',
    'CTA CHEST W&W/O C&RECONS, NON-CORONARY',
    'NLSA CT CHEST WITHOUT CONTRAST',
    'P CTA CHEST W&W/O C&RECONS, NON-CORONARY PORT')
    ) AS CT ON
  Admissions.HADM_ID = CT.HADM_ID

left join `physionet-data.mimiciii_clinical.icustays` ICUStayDim on
Admissions.HADM_ID = ICUStayDim.HADM_ID

left join (select ECGNote.SUBJECT_ID, ECGNote.HADM_ID, ECGNote.CHARTDATE, ECGNote.CATEGORY,
  ECGNote.DESCRIPTION, ECGNote.CGID, ECGNote.ISERROR, ECGNote.TEXT
  from `physionet-data.mimiciii_notes.noteevents` AS ECGNote

  where CATEGORY = 'ECG') AS ECG on
  Admissions.HADM_ID = ECG.HADM_ID
  
where (Dx.ICD9_CODE LIKE "415%"
    OR DrgDim.DRG_CODE in ("175", "176", "1341", "1342", "1343", "1344")
    OR (DrgDim.DRG_CODE in ("175", "176")
      AND DrgDim.DESCRIPTION != 'COMPLICATED PEPTIC ULCER'
      AND DrgDim.DESCRIPTION != 'GASTROINTESTINAL HEMORRHAGE WITHOUT COMPLICATIONS, COMORBIDITIES'))
  AND ADMISSION_LOCATION = 'EMERGENCY ROOM ADMIT';