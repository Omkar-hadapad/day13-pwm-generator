# Day 13 — PWM Generator

<p align="center">
  <b>Digital VLSI • Verilog RTL • Sequential Logic • Structural Design • Cadence Genus</b>
</p>

<p align="center">
  <code>Specification → RTL → Simulation → Synthesis → Technology Mapping → Area → Power → Timing → PPA Review</code>
</p>

<p align="center">
  <img alt="Status" src="https://img.shields.io/badge/Project-Day%2013-blue">
  <img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">
  <img alt="Tool" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">
  <img alt="Analysis" src="https://img.shields.io/badge/Analysis-Area%20%7C%20Power%20%7C%20Timing-success">
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Day 13 — PWM Generator |
| **Domain** | Digital VLSI / RTL Design |
| **Design Type** | Sequential counter with combinational comparison |
| **HDL** | Verilog HDL |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Library** | `tsmc18` (as used in the project flow) |
| **Operating Condition** | `slow (balanced_tree)` |
| **Wireload Mode** | `enclosed` |
| **Top Module in Report** | `pwm_top` |
| **Reported Design** | RTL and structural PWM implementation hierarchy |
| **Analysis** | Hierarchy, standard-cell area, power, timing |
| **Status** | Genus reports reviewed; physical-design/post-route closure is not established by these reports |

> **Measurement note:** The area report gives a total of `1007.899`, but the report context available here does not establish its physical unit. It is therefore reported as *area units*, not assumed to be µm².

---

## 2. Project Overview

Pulse-width modulation (PWM) controls the average power delivered to a load by changing the proportion of each period for which a digital output is high. This proportion is called the **duty cycle**.

A typical digital PWM architecture uses a counter and a comparison between the counter value and a duty-cycle threshold. The comparison determines the output state, while the counter establishes the repeating period.

This project is documented through the available Cadence Genus hierarchy, technology-mapping, area, power, and timing reports. The values below are reported synthesis-analysis results; they should not be interpreted as post-route results unless confirmed by a physical-design flow with extracted parasitics.

---

## 3. Objectives

1. Understand the digital PWM generation principle.
2. Relate counter operation and threshold comparison to PWM output behavior.
3. Review the RTL and structural implementation hierarchy.
4. Understand how Genus maps the design to standard cells.
5. Analyze total mapped area and cell-type distribution.
6. Interpret internal, switching, and leakage power.
7. Read a timing path and calculate slack.
8. Identify the limits of synthesis-stage reports.
9. Prepare the design for further physical-design and PPA investigation.

---

## 4. PWM Operating Principle

The duty cycle is the percentage of one PWM period during which the output is high.

\[
D(\%) = \frac{T_{\mathrm{ON}}}{T_{\mathrm{PERIOD}}}\times 100
\]

For example, a 25% duty cycle means the output is high for one-quarter of the period and low for the remaining three-quarters.

```text
PWM output, illustrative 25% duty cycle

HIGH  ┌───┐             ┌───┐
      │   │             │   │
LOW ──┘   └─────────────┘   └──────────
      <------ one period ------->
```

A common implementation compares a running counter against a duty threshold:

```text
Counter ─────┐
             ├── Comparator ─── PWM output
Duty value ──┘
```

The exact comparison operator and output polarity must be confirmed from the project RTL. They are not inferred from the hierarchy report alone.

---

## 5. Reported Architecture and Hierarchy

The Genus hierarchy report identifies the top module as `pwm_top` and lists both RTL and structural implementation branches.

```text
pwm_top
├── RTL (pwm_generator_rtl)
└── STRUCTURAL (pwm_generator_structural)
    ├── COMP (comparator_4bit)
    │   ├── C0 (comparator_1bit_30)
    │   │   └── A1 (and_gate_11)
    │   ├── C1 (comparator_1bit_31)
    │   │   └── A1 (and_gate_11_29)
    │   ├── C2 (comparator_1bit_32)
    │   │   └── A1 (and_gate_11_28)
    │   ├── C3 (comparator_1bit)
    │   │   └── A1 (and_gate_11_27)
    │   ├── X1 (xor_gate_10)
    │   ├── X2 (xor_gate_10_43)
    │   └── X3 (xor_gate_10_42)
    └── COUNTER (counter_4bit)
        ├── FF0 (dff_sync_reset)
        ├── FF1 (dff_sync_reset_3_33)
        ├── FF2 (dff_sync_reset_3_34)
        ├── FF3 (dff_sync_reset_3)
        └── INC (incrementer_4bit)
            ├── FA1 (full_adder_3_35)
            │   └── HA2 (half_adder_7_37)
            ├── FA2 (full_adder_3_36)
            │   └── HA2 (half_adder_7_38)
            └── FA3 (full_adder_3)
                └── HA2 (half_adder_7)
```

### Hierarchy observations

- The structural branch contains a 4-bit comparator and a 4-bit counter.
- The counter branch lists four synchronous-reset DFF instances and an incrementer.
- The incrementer hierarchy includes full-adder and half-adder blocks.
- The report also lists an RTL PWM generator branch.

**Interpretation limit:** A hierarchy listing does not by itself prove whether both PWM branches contribute to the active output logic, or whether one branch is unused/optimized. Confirm this by checking the `pwm_top` source and the synthesized netlist before treating the branches as two independent implementations or making a fair RTL-versus-structural comparison.

---

## 6. Genus Synthesis Summary

| Metric | Reported result |
|---|---:|
| Top module | `pwm_top` |
| Mapped standard-cell instances | 48 |
| Total reported cell area | 1007.899 area units |
| Total estimated power | 76.0343 µW |
| Timing path shown | Input-to-output, `duty[0]` → `pwm_rtl` |
| Path delay | 824 ps (0.824 ns) |
| Reported slack | +7176 ps (+7.176 ns) |
| Clock period in timing context | 10,000 ps (10 ns) |

These metrics come from the supplied Genus reports. They are not a substitute for checking all timing paths or a post-route implementation.

---

## 7. Hierarchy Area Analysis

The hierarchy area report contains the following values:

| Hierarchy block | Cell count | Reported area |
|---|---:|---:|
| `pwm_top` | 48 | 1007.899 |
| `pwm_generator_rtl` | 19 | 432.432 |
| `pwm_generator_structural` | 29 | 575.467 |
| `comparator_4bit` | 16 | 216.216 |
| `counter_4bit` | 13 | 359.251 |

### Observations

- The top-level report contains 48 cells with a reported area of `1007.899`.
- The structural branch is reported as `575.467`, compared with `432.432` for the RTL branch.
- The difference between those branch figures is `143.035` area units.
- This difference does **not** prove that structural RTL is inherently less area-efficient. A valid comparison requires equivalent functionality, identical constraints and libraries, consistent synthesis settings, and confirmation that the two implementations are isolated and evaluated independently.
- Do not add parent and child area values together: hierarchy child values are breakdowns of the reported design, not automatically additional area.

---

## 8. Standard-Cell Technology Mapping

The mapped cell report lists 48 standard-cell instances.

| Standard cell | Instances | Reported area |
|---|---:|---:|
| `AND2X2` | 7 | 93.139 |
| `AND3X2` | 1 | 16.632 |
| `AOI21X1` | 1 | 13.306 |
| `AOI2BB1XL` | 2 | 33.264 |
| `DFFHQX1` | 1 | 53.222 |
| `DFFTRX1` | 7 | 395.842 |
| `INVX1` | 8 | 53.222 |
| `INVXL` | 4 | 26.611 |
| `NAND2X1` | 2 | 19.958 |
| `NOR2BX1` | 1 | 13.306 |
| `NOR2X1` | 1 | 9.979 |
| `OAI21XL` | 3 | 39.917 |
| `OAI221XL` | 1 | 23.285 |
| `OAI2BB1X1` | 2 | 33.264 |
| `OAI2BB2XL` | 1 | 23.285 |
| `XOR2X1` | 6 | 159.667 |
| **Total** | **48** | **1007.899** |

### Cell-type distribution

| Category | Instances | Area | Share |
|---|---:|---:|---:|
| Sequential | 8 | 449.064 | 44.6% |
| Inverter | 12 | 79.834 | 7.9% |
| Logic | 28 | 479.002 | 47.5% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **48** | **1007.899** | **100%** |

### Main area contributors

- `DFFTRX1`: 7 instances, `395.842` area units.
- `XOR2X1`: 6 instances, `159.667` area units.
- `AND2X2`: 7 instances, `93.139` area units.

The report classifies eight instances as sequential cells, while the structural counter hierarchy lists four logical DFF instances. Do not assume that all eight sequential cells are independent counter bits. Inspect the mapped netlist and full hierarchy to determine the function and origin of each mapped cell.

---

## 9. Power Analysis

The Genus power report uses watts as its power unit.

| Category | Leakage | Internal | Switching | Total | Share |
|---|---:|---:|---:|---:|---:|
| Register | 1.25889e-08 W | 5.06958e-05 W | 2.51568e-06 W | 5.32241e-05 W | 70.00% |
| Logic | 2.30155e-08 W | 1.16999e-05 W | 4.81498e-06 W | 1.65379e-05 W | 21.75% |
| Clock | 0 W | 0 W | 6.27232e-06 W | 6.27232e-06 W | 8.25% |
| **Total** | **3.56044e-08 W** | **6.23957e-05 W** | **1.36030e-05 W** | **7.60343e-05 W** | **100%** |

### Power components

| Component | Power | Percentage |
|---|---:|---:|
| Internal power | 62.3957 µW | 82.06% |
| Switching power | 13.6030 µW | 17.89% |
| Leakage power | 0.0356044 µW | 0.05% |
| **Total** | **76.0343 µW** | **100%** |

### Interpretation

- **Total reported power:** `7.60343e-05 W` = **76.0343 µW**.
- The register category contributes 70.00% of the report's total power.
- Internal power is the largest reported component at 82.06%.
- Switching power is 17.89%; leakage is 0.05% in this report.

Dynamic switching power is commonly approximated by:

\[
P_{\mathrm{switching}}\approx \alpha C V^2 f
\]

where \(\alpha\) is switching activity, \(C\) is effective capacitance, \(V\) is supply voltage, and \(f\) is frequency.

**Power-report limitation:** The report identifies the activity frame as `/stim#0/frame#0`, but the provided excerpt does not fully establish activity quality, clock assumptions, extracted parasitics, or whether this is a post-route estimate. Treat `76.0343 µW` as the reported estimate for that analysis setup, not as confirmed final silicon or post-layout power.

---

## 10. Timing Analysis

The timing report shows one **input-to-output path**:

```text
duty[0]
  → NOR2BX1
  → OAI2BB1X1
  → OAI221XL
  → AND3X2
  → OAI21XL
  → pwm_rtl
```

### Reported timing values

| Timing item | Value |
|---|---:|
| Clock period | 10,000 ps (10 ns) |
| Input delay | 1,000 ps (1 ns) |
| Output delay | 1,000 ps (1 ns) |
| Data path delay | 824 ps (0.824 ns) |
| Arrival time at output | 1,824 ps (1.824 ns) |
| Required time | 9,000 ps (9 ns) |
| **Slack** | **+7,176 ps (+7.176 ns)** |
| Report status | **MET** |

Slack check:

\[
\text{Slack}=\text{Required Time}-\text{Arrival Time}
\]

\[
=9000-1824=7176\text{ ps}=7.176\text{ ns}
\]

The listed cell delays are:

| Cell | Cell delay |
|---|---:|
| `NOR2BX1` | 162 ps |
| `OAI2BB1X1` | 191 ps |
| `OAI221XL` | 148 ps |
| `AND3X2` | 205 ps |
| `OAI21XL` | 118 ps |
| **Total** | **824 ps** |

`AND3X2` has the largest individual cell delay on this particular path at 205 ps, followed by `OAI2BB1X1` at 191 ps.

### Timing interpretation and limitations

- The reported path is marked **MET** with +7.176 ns slack.
- This is an input-to-output path, not a register-to-register setup path.
- It is only one reported path; it does not establish that every setup and hold path meets timing.
- The report context shows `wireload mode enclosed`; it does not by itself establish routed interconnect timing.
- For stronger timing sign-off, review the complete worst-path reports, verify the SDC constraints, inspect register-to-register setup and hold paths, and run post-route timing with extracted parasitics.

---

## 11. PPA Summary

| Metric | Result | Evidence / qualification |
|---|---:|---|
| **Area** | 1007.899 area units | Genus mapped-cell report; physical unit not confirmed |
| **Power** | 76.0343 µW | Genus power estimate for `/stim#0/frame#0` |
| **Timing path delay** | 0.824 ns | One input-to-output path |
| **Slack** | +7.176 ns | Reported path status: MET |
| **Mapped cells** | 48 | Standard-cell area report |
| **Post-route status** | Not established | No extracted-parasitic/post-route evidence in the supplied reports |

These results form a **synthesis-stage report snapshot**. They should not be presented as final post-layout PPA until the physical-design stage has been run and its reports reviewed.

---

## 12. RTL and Structural Implementation Comparison

The hierarchy report includes `pwm_generator_rtl` and `pwm_generator_structural`.

| Item | RTL branch | Structural branch |
|---|---|---|
| Reported area | 432.432 | 575.467 |
| Reported cells | 19 | 29 |
| Difference in reported area | — | +143.035 relative to RTL branch |
| Fair comparison established? | No | No |

Before drawing a design-efficiency conclusion:

1. Confirm both branches implement the same behavior.
2. Inspect `pwm_top` to establish how the branches are instantiated and connected.
3. Synthesize each implementation separately with the same library and constraints.
4. Compare area, worst-path delay, power assumptions, and mapped cells under equivalent conditions.

---

## 13. Verification and Evidence Status

This README summarizes the Genus reports available for the project. The supplied report excerpts do not include enough information to independently certify all simulation tests or functional corner cases.

Recommended evidence to retain in the repository:

- RTL source files and top-level module.
- Testbench and simulator transcript.
- Waveform showing counter progression and PWM output.
- Genus hierarchy report.
- Standard-cell area report.
- Power report and activity assumptions.
- Timing report and SDC constraints.
- Mapped netlist and synthesis logs.
- If completed, floorplan/place-and-route reports and post-route timing/power reports.

Do not mark simulation, DRC/LVS, or post-route closure as complete unless the corresponding evidence exists.

---

## 14. Limitations and Next Improvements

1. Confirm the comparator operation and output polarity from the RTL.
2. Inspect `pwm_top` to confirm whether both listed implementation branches are active.
3. Resolve why the mapped report lists eight sequential cells while the structural counter hierarchy lists four DFF instances.
4. Validate the simulation testbench against boundary duty values and counter wraparound.
5. Check the SDC clock, input/output delays, and any false/multicycle path assumptions.
6. Generate and inspect full timing reports, including register-to-register paths.
7. Compare RTL and structural branches in separate, equivalent synthesis runs.
8. Continue through floorplanning, placement, clock-tree synthesis, routing, and extracted-parasitic analysis if those stages are part of the project environment.

---

## 15. Industry Relevance

PWM is used in digital control and power-management applications such as motor control, LED dimming, and switching-converter control. From a digital-design perspective, this project reinforces:

- Counter and comparator architecture.
- Sequential and combinational logic integration.
- RTL-versus-structural design styles.
- Standard-cell mapping and area distribution.
- Power-report interpretation.
- Timing constraints, path delay, and slack.
- Evidence-based PPA reporting.

---

## 16. Interview Questions

1. What is PWM, and how is duty cycle calculated?
2. How can a counter and comparator generate a PWM signal?
3. What determines the PWM period in a counter-based design?
4. What is the difference between RTL and structural Verilog?
5. Why can synthesis map equivalent RTL descriptions into different cell structures?
6. What is the difference between internal, switching, and leakage power?
7. What does positive timing slack mean?
8. Why does one MET path not prove full timing closure?
9. Why must the same constraints and library be used for a fair PPA comparison?
10. Why should synthesis-stage timing not automatically be described as post-route timing?

---

## 17. Project Status

| Stage | Status |
|---|---|
| Project hierarchy reviewed | Complete for the available report |
| Standard-cell area reviewed | Complete for the available report |
| Power report reviewed | Complete for the available report |
| One timing path reviewed | Complete for the available report |
| Functional simulation certification | Not established by the supplied report excerpts |
| Equivalent RTL/structural comparison | Pending independent runs and top-level confirmation |
| Post-route PPA closure | Not established |

---

## 18. Final Genus Results

| Parameter | Reported value |
|---|---:|
| Top module | `pwm_top` |
| Standard-cell count | 48 |
| Total area | 1007.899 area units |
| Total power | 76.0343 µW |
| Input-to-output path delay | 0.824 ns |
| Path slack | +7.176 ns |
| Path status | MET |
| Post-route status | Not established |

**Conclusion:** The available Genus reports provide a useful synthesis-stage view of the PWM design's hierarchy, mapped area, estimated power, and one timing path. The next step is to validate the RTL/top-level connectivity and functional simulation, then review full timing coverage and physical-design results before making post-layout PPA claims.

---

## 19. Next Project — Day 14: 1011 Sequence Detector

The next project moves from a counter-based PWM design into **finite-state machine (FSM) design**.

**Planned focus:**
- Detect the serial bit pattern `1011`.
- Define the state diagram and state-transition table.
- Implement the FSM in synthesizable Verilog.
- Build a testbench for detection, non-detection, reset, and overlapping input sequences where supported by the chosen specification.
- Compare Moore and Mealy approaches if included in the project scope.
- Run simulation and review the Genus synthesis, area, power, and timing reports.

**Key learning goal:** translate a sequence-detection specification into states, transitions, RTL, and a testbench that demonstrates correct behavior.

---

## 20. Suggested Repository Structure

```text
day13-pwm-generator/
├── rtl/
│   ├── pwm_top.v
│   ├── pwm_generator_rtl.v
│   ├── pwm_generator_structural.v
│   ├── counter_4bit.v
│   ├── incrementer_4bit.v
│   └── comparator_4bit.v
├── tb/
│   └── pwm_generator_tb.v
├── sim/
│   ├── waveform/
│   └── simulation.log
├── genus/
│   ├── constraints_top.sdc
│   ├── reports/
│   │   ├── hierarchy.rpt
│   │   ├── area.rpt
│   │   ├── power.rpt
│   │   └── timing.rpt
│   ├── mapped_netlist.v
│   └── synthesis.log
├── docs/
│   └── architecture.md
└── README.md
```

> Adjust filenames to match the actual repository. The structure above is a suggested organization, not a claim that every listed file was supplied or generated.

---

## 21. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering  
Digital VLSI • Verilog RTL • Cadence Genus

---

<p align="center">
  <b>Day 13 Complete — Next: Day 14 · 1011 Sequence Detector</b>
</p>
