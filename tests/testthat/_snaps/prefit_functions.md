# prefit_csf_agep_to_age5p()

    Code
      xtabs(~ agep + age5p, data = fitting_problem$refSample)
    Output
                         age5p
      agep                0-4 years 10-14 years 15-19 years 20-24 years 25-29 years
        0 years                  30           0           0           0           0
        1 year                   38           0           0           0           0
        10 years                  0          18           0           0           0
        11 years                  0          26           0           0           0
        12 years                  0          29           0           0           0
        13 years                  0          14           0           0           0
        14 years                  0          23           0           0           0
        15 years                  0           0          20           0           0
        16 years                  0           0          22           0           0
        17 years                  0           0          22           0           0
        18 years                  0           0          29           0           0
        19 years                  0           0          28           0           0
        2 years                  37           0           0           0           0
        20 years                  0           0           0          28           0
        21 years                  0           0           0          31           0
        22 years                  0           0           0          38           0
        23 years                  0           0           0          39           0
        24 years                  0           0           0          41           0
        25-29 years               0           0           0           0         266
        3 years                  36           0           0           0           0
        30-34 years               0           0           0           0           0
        35-39 years               0           0           0           0           0
        4 years                  30           0           0           0           0
        40-44 years               0           0           0           0           0
        45-49 years               0           0           0           0           0
        5 years                   0           0           0           0           0
        50-54 years               0           0           0           0           0
        55-59 years               0           0           0           0           0
        6 years                   0           0           0           0           0
        60-64 years               0           0           0           0           0
        65-69 years               0           0           0           0           0
        7 years                   0           0           0           0           0
        70-74 years               0           0           0           0           0
        75-79 years               0           0           0           0           0
        8 years                   0           0           0           0           0
        80-84 years               0           0           0           0           0
        85 years and over         0           0           0           0           0
        9 years                   0           0           0           0           0
                         age5p
      agep                30-34 years 35-39 years 40-44 years 45-49 years 5-9 years
        0 years                     0           0           0           0         0
        1 year                      0           0           0           0         0
        10 years                    0           0           0           0         0
        11 years                    0           0           0           0         0
        12 years                    0           0           0           0         0
        13 years                    0           0           0           0         0
        14 years                    0           0           0           0         0
        15 years                    0           0           0           0         0
        16 years                    0           0           0           0         0
        17 years                    0           0           0           0         0
        18 years                    0           0           0           0         0
        19 years                    0           0           0           0         0
        2 years                     0           0           0           0         0
        20 years                    0           0           0           0         0
        21 years                    0           0           0           0         0
        22 years                    0           0           0           0         0
        23 years                    0           0           0           0         0
        24 years                    0           0           0           0         0
        25-29 years                 0           0           0           0         0
        3 years                     0           0           0           0         0
        30-34 years               254           0           0           0         0
        35-39 years                 0         231           0           0         0
        4 years                     0           0           0           0         0
        40-44 years                 0           0         199           0         0
        45-49 years                 0           0           0         179         0
        5 years                     0           0           0           0        30
        50-54 years                 0           0           0           0         0
        55-59 years                 0           0           0           0         0
        6 years                     0           0           0           0        32
        60-64 years                 0           0           0           0         0
        65-69 years                 0           0           0           0         0
        7 years                     0           0           0           0        23
        70-74 years                 0           0           0           0         0
        75-79 years                 0           0           0           0         0
        8 years                     0           0           0           0        38
        80-84 years                 0           0           0           0         0
        85 years and over           0           0           0           0         0
        9 years                     0           0           0           0        15
                         age5p
      agep                50-54 years 55-59 years 60-64 years 65-69 years 70-74 years
        0 years                     0           0           0           0           0
        1 year                      0           0           0           0           0
        10 years                    0           0           0           0           0
        11 years                    0           0           0           0           0
        12 years                    0           0           0           0           0
        13 years                    0           0           0           0           0
        14 years                    0           0           0           0           0
        15 years                    0           0           0           0           0
        16 years                    0           0           0           0           0
        17 years                    0           0           0           0           0
        18 years                    0           0           0           0           0
        19 years                    0           0           0           0           0
        2 years                     0           0           0           0           0
        20 years                    0           0           0           0           0
        21 years                    0           0           0           0           0
        22 years                    0           0           0           0           0
        23 years                    0           0           0           0           0
        24 years                    0           0           0           0           0
        25-29 years                 0           0           0           0           0
        3 years                     0           0           0           0           0
        30-34 years                 0           0           0           0           0
        35-39 years                 0           0           0           0           0
        4 years                     0           0           0           0           0
        40-44 years                 0           0           0           0           0
        45-49 years                 0           0           0           0           0
        5 years                     0           0           0           0           0
        50-54 years               122           0           0           0           0
        55-59 years                 0         117           0           0           0
        6 years                     0           0           0           0           0
        60-64 years                 0           0         119           0           0
        65-69 years                 0           0           0          95           0
        7 years                     0           0           0           0           0
        70-74 years                 0           0           0           0          82
        75-79 years                 0           0           0           0           0
        8 years                     0           0           0           0           0
        80-84 years                 0           0           0           0           0
        85 years and over           0           0           0           0           0
        9 years                     0           0           0           0           0
                         age5p
      agep                75-79 years 80-84 years 85 years and over
        0 years                     0           0                 0
        1 year                      0           0                 0
        10 years                    0           0                 0
        11 years                    0           0                 0
        12 years                    0           0                 0
        13 years                    0           0                 0
        14 years                    0           0                 0
        15 years                    0           0                 0
        16 years                    0           0                 0
        17 years                    0           0                 0
        18 years                    0           0                 0
        19 years                    0           0                 0
        2 years                     0           0                 0
        20 years                    0           0                 0
        21 years                    0           0                 0
        22 years                    0           0                 0
        23 years                    0           0                 0
        24 years                    0           0                 0
        25-29 years                 0           0                 0
        3 years                     0           0                 0
        30-34 years                 0           0                 0
        35-39 years                 0           0                 0
        4 years                     0           0                 0
        40-44 years                 0           0                 0
        45-49 years                 0           0                 0
        5 years                     0           0                 0
        50-54 years                 0           0                 0
        55-59 years                 0           0                 0
        6 years                     0           0                 0
        60-64 years                 0           0                 0
        65-69 years                 0           0                 0
        7 years                     0           0                 0
        70-74 years                 0           0                 0
        75-79 years                54           0                 0
        8 years                     0           0                 0
        80-84 years                 0          62                 0
        85 years and over           0           0                46
        9 years                     0           0                 0

---

    Code
      xtabs(~ agep + age5p, data = fitting_problem$refSample)
    Output
                         age5p
      agep                0-4 years 10-14 years 15-19 years 20-24 years 25-29 years
        0 years                  29           0           0           0           0
        1 year                   35           0           0           0           0
        10 years                  0          25           0           0           0
        11 years                  0          24           0           0           0
        12 years                  0          33           0           0           0
        13 years                  0          22           0           0           0
        14 years                  0          22           0           0           0
        15 years                  0           0          22           0           0
        16 years                  0           0           9           0           0
        17 years                  0           0          24           0           0
        18 years                  0           0          29           0           0
        19 years                  0           0          37           0           0
        2 years                  24           0           0           0           0
        20 years                  0           0           0          38           0
        21 years                  0           0           0          40           0
        22 years                  0           0           0          34           0
        23 years                  0           0           0          50           0
        24 years                  0           0           0          45           0
        25-29 years               0           0           0           0         288
        3 years                  28           0           0           0           0
        30-34 years               0           0           0           0           0
        35-39 years               0           0           0           0           0
        4 years                  25           0           0           0           0
        40-44 years               0           0           0           0           0
        45-49 years               0           0           0           0           0
        5 years                   0           0           0           0           0
        50-54 years               0           0           0           0           0
        55-59 years               0           0           0           0           0
        6 years                   0           0           0           0           0
        60-64 years               0           0           0           0           0
        65-69 years               0           0           0           0           0
        7 years                   0           0           0           0           0
        70-74 years               0           0           0           0           0
        75-79 years               0           0           0           0           0
        8 years                   0           0           0           0           0
        80-84 years               0           0           0           0           0
        85 years and over         0           0           0           0           0
        9 years                   0           0           0           0           0
                         age5p
      agep                30-34 years 35-39 years 40-44 years 45-49 years 5-9 years
        0 years                     0           0           0           0         0
        1 year                      0           0           0           0         0
        10 years                    0           0           0           0         0
        11 years                    0           0           0           0         0
        12 years                    0           0           0           0         0
        13 years                    0           0           0           0         0
        14 years                    0           0           0           0         0
        15 years                    0           0           0           0         0
        16 years                    0           0           0           0         0
        17 years                    0           0           0           0         0
        18 years                    0           0           0           0         0
        19 years                    0           0           0           0         0
        2 years                     0           0           0           0         0
        20 years                    0           0           0           0         0
        21 years                    0           0           0           0         0
        22 years                    0           0           0           0         0
        23 years                    0           0           0           0         0
        24 years                    0           0           0           0         0
        25-29 years                 0           0           0           0         0
        3 years                     0           0           0           0         0
        30-34 years               272           0           0           0         0
        35-39 years                 0         221           0           0         0
        4 years                     0           0           0           0         0
        40-44 years                 0           0         182           0         0
        45-49 years                 0           0           0         192         0
        5 years                     0           0           0           0        28
        50-54 years                 0           0           0           0         0
        55-59 years                 0           0           0           0         0
        6 years                     0           0           0           0        29
        60-64 years                 0           0           0           0         0
        65-69 years                 0           0           0           0         0
        7 years                     0           0           0           0        28
        70-74 years                 0           0           0           0         0
        75-79 years                 0           0           0           0         0
        8 years                     0           0           0           0        26
        80-84 years                 0           0           0           0         0
        85 years and over           0           0           0           0         0
        9 years                     0           0           0           0        28
                         age5p
      agep                50-54 years 55-59 years 60-64 years 65-69 years 70-74 years
        0 years                     0           0           0           0           0
        1 year                      0           0           0           0           0
        10 years                    0           0           0           0           0
        11 years                    0           0           0           0           0
        12 years                    0           0           0           0           0
        13 years                    0           0           0           0           0
        14 years                    0           0           0           0           0
        15 years                    0           0           0           0           0
        16 years                    0           0           0           0           0
        17 years                    0           0           0           0           0
        18 years                    0           0           0           0           0
        19 years                    0           0           0           0           0
        2 years                     0           0           0           0           0
        20 years                    0           0           0           0           0
        21 years                    0           0           0           0           0
        22 years                    0           0           0           0           0
        23 years                    0           0           0           0           0
        24 years                    0           0           0           0           0
        25-29 years                 0           0           0           0           0
        3 years                     0           0           0           0           0
        30-34 years                 0           0           0           0           0
        35-39 years                 0           0           0           0           0
        4 years                     0           0           0           0           0
        40-44 years                 0           0           0           0           0
        45-49 years                 0           0           0           0           0
        5 years                     0           0           0           0           0
        50-54 years               135           0           0           0           0
        55-59 years                 0         112           0           0           0
        6 years                     0           0           0           0           0
        60-64 years                 0           0         115           0           0
        65-69 years                 0           0           0         114           0
        7 years                     0           0           0           0           0
        70-74 years                 0           0           0           0          92
        75-79 years                 0           0           0           0           0
        8 years                     0           0           0           0           0
        80-84 years                 0           0           0           0           0
        85 years and over           0           0           0           0           0
        9 years                     0           0           0           0           0
                         age5p
      agep                75-79 years 80-84 years 85 years and over
        0 years                     0           0                 0
        1 year                      0           0                 0
        10 years                    0           0                 0
        11 years                    0           0                 0
        12 years                    0           0                 0
        13 years                    0           0                 0
        14 years                    0           0                 0
        15 years                    0           0                 0
        16 years                    0           0                 0
        17 years                    0           0                 0
        18 years                    0           0                 0
        19 years                    0           0                 0
        2 years                     0           0                 0
        20 years                    0           0                 0
        21 years                    0           0                 0
        22 years                    0           0                 0
        23 years                    0           0                 0
        24 years                    0           0                 0
        25-29 years                 0           0                 0
        3 years                     0           0                 0
        30-34 years                 0           0                 0
        35-39 years                 0           0                 0
        4 years                     0           0                 0
        40-44 years                 0           0                 0
        45-49 years                 0           0                 0
        5 years                     0           0                 0
        50-54 years                 0           0                 0
        55-59 years                 0           0                 0
        6 years                     0           0                 0
        60-64 years                 0           0                 0
        65-69 years                 0           0                 0
        7 years                     0           0                 0
        70-74 years                 0           0                 0
        75-79 years                64           0                 0
        8 years                     0           0                 0
        80-84 years                 0          48                 0
        85 years and over           0           0                70
        9 years                     0           0                 0

# prefit_control_retotal

    Code
      fitting_problem$controls$individual
    Output
      $`118011339`
            sexp           mstp count
       1:   Male  Never married    22
       2:   Male        Widowed     1
       3:   Male       Divorced     3
       4:   Male      Separated     1
       5:   Male        Married    15
       6:   Male Not applicable     8
       7: Female  Never married    21
       8: Female        Widowed     2
       9: Female       Divorced     3
      10: Female      Separated     1
      11: Female        Married    16
      12: Female Not applicable     7
      
      $`118011339`
                                            occp count
       1:                               Managers    11
       2:                          Professionals    22
       3:         Technicians and Trades Workers     4
       4: Community and Personal Service Workers     5
       5:    Clerical and Administrative Workers     6
       6:                          Sales Workers     4
       7:        Machinery Operators and Drivers     1
       8:                              Labourers     2
       9:                 Inadequately described     1
      10:                             Not stated     0
      11:                         Not applicable    43
      

---

    Code
      fitting_problem$controls$group
    Output
      $`118011339`
                   nprd count
      1:     One person    22
      2:    Two persons    30
      3:  Three persons    13
      4:   Four persons    11
      5:   Five persons     4
      6:    Six persons     1
      7: Not applicable    20
      

