# データアナリスト　ポートフォリオ

## 自己紹介

約7年間、人事・労務業務に従事してきました。
現在はデータアナリストへの転職を目指し、
SQL・Python・pandasを中心に学習しています。

データ分析を通じて、
業務改善に貢献できるアナリストを目指しています。

## スキル

- SQL
- Python
- pandas
- PowerBI
- Excel
- Word
- PowerPoint

# Employee Analytics｜Department Analysis

## 概要

架空の従業員データを用いて、部署（Department）と役職（JobTitle）による給与水準の違いを分析しました。

本分析では、部署別・役職別の平均 `TotalSalary` を比較し、データ生成時に設定した給与ルールが想定どおり反映されているかを確認します。

## 使用データ

- 架空の従業員データ
- 主な項目：Department、JobTitle、BaseSalary、PositionAllowance、TotalSalary

## 分析結果

### Department別の平均TotalSalary

| Department | 平均TotalSalary |
|---|---:|
| Engineering | 272,492円 |
| Finance | 257,688円 |
| Human Resources | 239,575円 |

Engineeringは、全部署の中で最も平均TotalSalaryが高い結果となりました。

![Department別の平均TotalSalary](images/department_average_total_salary.png)

### Department × JobTitle別の平均TotalSalary

- 全部署で、給与水準は **Manager ＞ Senior ＞ Staff** の順でした。
- Engineeringは、Staff・Senior・Managerのすべての役職で最も高い給与水準でした。

![Department・JobTitle別の平均TotalSalary](images/department_jobtitle_salary.png)

## Insights（考察）

### 1. Departmentによる給与水準の違い

Engineeringの平均TotalSalaryが最も高いことが確認できました。さらに、同じJobTitleで比較してもEngineeringの給与水準が高いため、役職構成だけではなく、Departmentごとの基本給水準が影響していると考えられます。

今回の架空データでは、EngineeringのBaseSalaryを他部署より高く設定しており、その設定がTotalSalaryの差に反映されています。

### 2. JobTitleによる給与水準の違い

全部署でManager ＞ Senior ＞ Staffの順に給与水準が高いことが確認できました。

これは、JobTitleが上がるほどPositionAllowanceを高く設定した給与ルールと一致しています。

### 3. データ生成ルールの妥当性

Department別のBaseSalaryとJobTitle別のPositionAllowanceの設定が、TotalSalaryの差として想定どおり反映されていることを確認できました。

したがって、本データは設定した給与ルールに整合した架空データであるといえます。

## 分析ファイル

- [詳細レポート](docs/department_analysis.md)
- [分析Notebook](notebooks/department_analysis.ipynb)
- [使用データ](data/employee_data.csv)

## 今後追加予定

- SQL分析
- Power BIダッシュボード
