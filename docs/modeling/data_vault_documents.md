# 🏗️ Data Architecture: Data Vault 2.0 (Hospital DWH)

This document provides a detailed description of the data layers within the Data Warehouse system, built according to **Data Vault 2.0** standards using **dbt**. The dbt documents you can access at [dbt web docs](http://localhost:8183).

---

## 📂 1. Staging Layer (`models/staging/`)
The Data Preparation layer serves as the primary gateway to the Warehouse.

### 1.1 Pre-Staging Layer (`_prep.sql`)
Before performing hashing, `_prep` files execute several critical tasks:
*   **Business Key Resolution**: Joining transactional data with master catalogs to retrieve **Business Codes** (e.g., converting system `staff_id` to business `staff_code`).
*   **Data Cleaning**: Type casting and handling basic formatting issues from the Lake.
*   **Output**: An intermediate flat view containing all necessary attributes for the Raw Vault layer.

### 1.2 Official Hashing Layer (`stg_*.sql`)
Utilizes the `automate_dv.stage` macro to perform Hashing. This is the final staging model before ingestion into the Vault.
*   **Source**: Mapped from the **Pre-Staging** layer (preferred) or directly from the **Data Lake**.
*   **Technical Specifications**:
    *   **Hard Rules**: Source data remains unchanged (preserving original state).
    *   **Metadata Enrichment**: Adding technical columns: `LOAD_DATETIME`, `RECORD_SOURCE`.
    *   **Hashing**: Calculating Hash Keys (`_PK`) and Hash Diff (`HASHDIFF`).

#### **Detailed Model List**:

**A. Master Data & Entities**
| dbt Model (Hashing) | Pre-Staging (`_prep`) | Source Table (Lake) | Business Key (BK) |
| :--- | :--- | :--- | :--- |
| `stg_dm_benh_nhan` | Direct mapping | `dm_benh_nhan` | `nb_thong_tin_id` |
| `stg_dm_nhan_vien` | Direct mapping | `dm_nhan_vien` | `code_nhan_vien` |
| `stg_dm_khoa` | Direct mapping | `dm_khoa` | `code_khoa` |
| `stg_dm_phong` | `stg_dm_phong_prep` | `dm_phong` | `code_phong` |
| `stg_dm_dich_vu` | Direct mapping | `dm_dich_vu` | `code_dichvu` |
| `stg_dm_bo_chi_dinh` | Direct mapping | `dm_bo_chi_dinh` | `code_bo_chi_dinh` |
| `stg_dm_dv_discount` | Direct mapping | `dm_dv_discount` | `id` |
| `stg_dm_hop_dong_ksk` | Direct mapping | `dm_hop_dong_ksk` | `ma_hop_dong` |
| `stg_dm_nhom_dv_cap1` | Direct mapping | `dm_nhom_dich_vu_cap1` | `ma_nhom` |
| `stg_dm_nhom_dv_cap2` | Direct mapping | `dm_nhom_dich_vu_cap2` | `ma_nhom` |
| `stg_dm_nhom_dv_cap3` | Direct mapping | `dm_nhom_dich_vu_cap3` | `ma_nhom` |

**B. Transactional Data**
| dbt Model (Hashing) | Pre-Staging (`_prep`) | Source Table (Lake) | Business Context |
| :--- | :--- | :--- | :--- |
| `stg_dot_dieu_tri` | `stg_ct_dot_dieu_tri_prep`| `ct_dot_dieu_tri` | Admission/Treatment records |
| `stg_dv_kham` | `stg_ct_dv_kham_prep` | `ct_dv_kham` | Examination & Diagnosis details |
| `stg_ct_dich_vu` | `stg_ct_dich_vu_prep` | `ct_dich_vu` | Service/Lab prescriptions |
| `stg_phieu_thu` | `stg_ct_phieu_thu_prep` | `ct_phieu_thu` | Financial transactions/Invoices |
| `stg_ct_dv_ky_thuat` | - | `ct_dv_ky_thuat` | Technical service execution results |
| `stg_ct_bo_chi_dinh` | - | `ct_bo_chi_dinh` | Attached instruction sets |
| `stg_ct_kham_suc_khoe`| - | `ct_kham_suc_khoe` | Corporate health checkups |
| `stg_ct_nguon_nb` | - | `ct_nguon_nb` | Patient source information |
| `stg_ct_dv_kham_kl` | - | `ct_dv_kham_ket_luan`| Final medical conclusions |

---

## 📂 2. Reference Layer (`models/reference/`)
Stores reference information and supplementary master catalogs.
*   **Purpose**: Provides context for data but **does not directly participate in complex calculations** or key hashing.
*   **Characteristics**:
    *   Static or slowly changing categorical data.
    *   Does not utilize the Hub-Link-Satellite model to minimize query complexity.

| dbt Model | Business Meaning |
| :--- | :--- |
| `ref_dia_gioi_hanh_chinh` | Administrative map (Province, District, Ward) |
| `ref_doi_tuong_kcb` | Patient categories (Insurance, Service, etc.) |
| `ref_hospital_configs` | System-wide hospital parameters |
| `ref_chuyen_khoa` | List of medical specialties |

---

## 📂 3. Raw Vault Layer (`models/raw_vault/`)
The core layer for permanent historical data storage, built from the Staging layer.

### 3.1 Hubs (`/hubs/`)
Stores unique lists of Business Keys (BK).
| dbt Model | Business Key (BK) | Business Context |
| :--- | :--- | :--- |
| `hub_benh_nhan` | `nb_thong_tin_id` | Unique Patient identifier |
| `hub_nhan_vien` | `code_nhan_vien` | Unique Staff identifier |
| `hub_dich_vu` | `code_dichvu` | Service/Catalog identifier |
| `hub_khoa` | `code_khoa` | Department/Ward identifier |
| `hub_phong` | `code_phong` | Room identifier |
| `hub_dot_dieu_tri`| `id` | Treatment encounter identifier |
| `hub_phieu_thu` | `id` | Invoice/Receipt identifier |
| `hub_bo_chi_dinh` | `code_bo_chi_dinh` | Instruction set identifier |
| `hub_nhom_dv_cap1/2/3`| `ma_nhom` | Service group hierarchy |

### 3.2 Links (`/links/`)
Stores relationships (Unit of Work) between Hubs.
| dbt Model | Connected Hubs | Business Context |
| :--- | :--- | :--- |
| `link_benh_nhan_dieu_tri`| `Hub_BenhNhan` ↔ `Hub_DotDieuTri` | Links patient to treatment records |
| `link_kham_benh` | `Hub_DotDieuTri` ↔ `Hub_NhanVien` | Doctor performing the exam |
| `link_chi_dinh_dich_vu` | `Hub_DotDT` ↔ `Hub_DV` ↔ `Hub_NV` ↔ `Hub_Khoa` | Detailed service prescription |
| `link_thanh_toan` | `Hub_PhieuThu` ↔ `Hub_DotDieuTri` | Payment for treatment records |
| `link_dv_ky_thuat` | `Hub_DotDieuTri` ↔ `Hub_DichVu` | Technical service execution log |
| `link_dot_dieu_tri_khoa` | `Hub_DotDieuTri` ↔ `Hub_Khoa` | Patient transfers between departments |
| `link_nguon_nb` | `Hub_DotDieuTri` ↔ `Hub_NguonNB` | Patient source channel |
| `link_nhom_dv_cap1_2_3` | `Hub_Cap1` ↔ `Hub_Cap2` ↔ `Hub_Cap3` | Service hierarchy structure |

### 3.3 Satellites (`/satellites/`)
Stores descriptive attributes and historical changes (SCD Type 2).
| dbt Model | Parent Entity | Primary Payload |
| :--- | :--- | :--- |
| `sat_benh_nhan` | `hub_benh_nhan` | Name, DOB, Address, Phone |
| `sat_nhan_vien` | `hub_nhan_vien` | Name, Position, License Number |
| `sat_dot_dieu_tri` | `hub_dot_dieu_tri` | Diagnosis, Admission status, Category |
| `sat_chi_dinh_dich_vu` | `link_chi_dinh_dich_vu` | Quantity, Price, Patient pay amount |
| `sat_thanh_toan` | `link_thanh_toan` | Total, Payment method, Invoice date |
| `sat_dv_ky_thuat` | `link_dv_ky_thuat` | Results, Execution end time |
| `sat_khoa` | `hub_khoa` | Department name, Symbol |
| `sat_phong` | `hub_phong` | Room name, Room type |
| `sat_kham_benh` | `link_kham_benh` | Exam time, Preliminary diagnosis |
| `sat_kham_ket_luan` | `link_kham_benh` | Final medical conclusion |

---

## 📂 4. Data Mart Layer (`models/data_mart/`)
The final presentation layer providing data for BI Tools (Superset). Organized in a **Star Schema** (Facts and Dimensions).

#### **A. Dimensions (Dim Tables)**
| Model | Primary Key (PK) | Descriptive Content |
| :--- | :--- | :--- |
| `dim_benh_nhan` | `BENH_NHAN_PK` | Name, code, age, address |
| `dim_nhan_vien` | `NHAN_VIEN_PK` | Name, employee code, role |
| `dim_dich_vu` | `DICH_VU_PK` | Service name, price, group |
| `dim_dot_dieu_tri`| `DOT_DIEU_TRI_PK` | Encounter code, diagnosis, status |
| `dim_khoa_phong` | `DON_VI_PK` | Ward/Department name, unit type |
| `dim_phieu_thu` | `PHIEU_THU_PK` | Receipt code, date, payment type |

#### **B. Facts (Fact Tables)**
| Model | Foreign Keys (FKs) | Metrics (Measures) |
| :--- | :--- | :--- |
| `fact_chi_dinh_dich_vu`| `BN`, `DotDT`, `DV`, `NV`, `Khoa` | Qty, Base Price, Net Amount |
| `fact_thanh_toan` | `BN`, `DotDT`, `PhieuThu` | Total, Discount, Actual Paid |
| `fact_kham_benh` | `BN`, `DotDT`, `NV (Doctor)` | Visit count, waiting time |
| `fact_dv_ky_thuat` | `BN`, `DotDT`, `DV`, `Khoa` | Qty, result, execution time |
| `fact_nguon_nb` | `BN`, `DotDT` | Patient source distribution |
| `fact_doanh_thu` | `Service` / `Dept` | Total Revenue, Growth % |

---

## 🛠️ Technical Standardization

### 1. Hashing Mechanism
- **Algorithm**: MD5.
- **Rule**: All Hex strings must be UPPERCASE for cross-platform consistency.
- **Tools**: `automate_dv.stage` macro for automated key generation.

### 2. Metadata Columns (Mandatory)
1.  `LOAD_DATETIME`: Timestamp when the record was loaded into the Warehouse.
2.  `RECORD_SOURCE`: Original source system identifier (e.g., `HIS_LAKE`).
3.  `EFFECTIVE_FROM`: Business timestamp when the record became valid.

### 3. Loading Strategy
- **Staging Layer**: Materialized as **Views** to ensure real-time access to Lake data.
- **Vault Layer**: Materialized as **Incremental** (delta loading).
- **Idempotency**: The system allows reprocessing without duplication (via PK and HashDiff verification).

---
*Document automatically updated based on actual dbt project structure.*
