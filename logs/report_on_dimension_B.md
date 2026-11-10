# Report on Dimension B

Date: 2026-06-10

## Scope

This report reviews:

- `code/04-indicadores-B.R`
- `code/helpers/calcula_dimensao_B.R`

The review covered the intended calculations, handling of missing values, join
integrity, label completeness, and output accounting invariants.

## Overall Assessment

The scripts currently run successfully and appear to implement the intended
decomposition of the net change in entrants and enrollments.

## Verdict

`code/04-indicadores-B.R` works as intended for the current data and indicator
definition.

It successfully calculates each group's contribution to the net change in
entrants and enrollments. The outputs reconcile exactly with national totals,
percentages sum to 100%, labels are complete, and structural missing values are
correctly treated as zero.

However, the script has limited safeguards against unexpected inputs:

- Genuine missing measurements or missing years would silently become zero.
- A period with zero total net change would produce `Inf` or `NaN`
  percentages.
- Implicit joins could silently cause problems if input keys change.

Therefore, the current results are correct, but the scripts are not fully
robust to future data problems.

For the current data:

- Every year from 2010 through 2024 is present.
- There are no missing deltas, non-finite percentages, or missing labels.
- Every block-period's deltas exactly reproduce the corresponding national
  total.
- Percentages sum to 100% within every block-period.
- Turn-based totals exactly equal the original entrant and enrollment totals
  for every year.
- The relevant join keys are unique and there are no unmatched records.

## Findings

### 1. Missing values are always interpreted as zero

Both scripts aggregate quantities using `sum(..., na.rm = TRUE)`:

- `code/04-indicadores-B.R`, line 45
- `code/helpers/calcula_dimensao_B.R`, lines 19 and 23-26

This means:

- An absent group-period is treated as zero, which correctly handles groups
  entering or leaving the observed population.
- A genuinely unknown measurement is also treated as zero.
- An entirely absent year would be treated as zero rather than reported as
  missing or causing an error.

This behavior is correct for the current data. The 15,620 rows with missing
selected quantity fields are structural `tp_dimensao == 3` records from
2010-2019. Repository documentation states that these records do not
contribute entrants or enrollments and may be ignored or treated as zero.

However, the scripts would silently produce misleading results if unexpected
missing measurements or an incomplete year appeared in future inputs.

### 2. Zero net change produces non-finite percentages

In `code/helpers/calcula_dimensao_B.R`, lines 31-32, each group's delta is
divided by the total delta for its block and period.

If the group-level changes sum to zero, the resulting percentages are `Inf`,
`-Inf`, or `NaN`. For example, changes of `+5` and `-5` have a zero net
denominator.

No current block-period has a zero denominator, so the current outputs are not
affected.

### 3. Percentages are contributions to net change

The calculated percentages are not conventional shares bounded between 0% and
100%. They measure each group's contribution to the net saldo.

Negative percentages and percentages above 100% are therefore mathematically
expected when groups move in opposite directions. Current outputs contain
absolute percentage values as large as approximately 1,187%.

This is correct if the intended indicator is the appropriation or
decomposition of net change. It would not be correct if the intended indicator
were a bounded distribution.

### 4. Input joins rely on implicit keys

In `code/04-indicadores-B.R`, line 42, `reduce(inner_join)` relies on the
columns shared by each pair of data frames and does not explicitly validate
join relationships.

The current inputs have unique relevant keys and no unmatched records, so the
present calculations are correct. Future changes to the input schemas or key
uniqueness could silently multiply or discard observations.

## Conclusion

The Dimension B scripts work as intended for the current inputs and indicator
definition. Their main weakness is robustness: unexpected missing values,
missing years, zero net-change denominators, or changed join keys could produce
misleading or non-finite outputs without an explicit validation error.
