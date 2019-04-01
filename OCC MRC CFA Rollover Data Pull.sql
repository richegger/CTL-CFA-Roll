DEFINE start_date     = TO_DATE('01-OCT-2018');
DEFINE end_date       = TO_DATE('30-OCT-2018');
DEFINE old_start_date = TO_DATE('01-SEP-2018');
DEFINE old_end_date   = TO_DATE('30-SEP-2018');
WITH 
  rollover AS (
    SELECT 
      vendor_name,
      BAN,
      bill_date,
      ec_circuit_id,
      strip_ec_circuit_id,
      usoc,
      bill_amt
    FROM
      custom_occ
    WHERE
      phrase_code = '751' and
      usoc like 'NR6%' and
      bill_date between &start_date and &end_date and
      vendor_name in ('CENTURYLINK', 'QWEST')),
  install AS (
    SELECT
      vendor_name,
      BAN,
      bill_date,
      ec_circuit_id,
      strip_ec_circuit_id,
      usoc,
      bill_amt
    FROM
      custom_occ
    WHERE
      phrase_code = '751' and
      usoc like 'T%' and
      bill_date between &start_date and &end_date and
      vendor_name in ('CENTURYLINK', 'QWEST')),
  newMRC AS (
    SELECT DISTINCT
      vendor_name,
      BAN,
      bill_date,
      ec_circuit_id,
      strip_ec_circuit_id,
      a_cfa as new_cfa,
      circuit_loc_addr as new_address
    FROM
      custom_mod_csr
    WHERE
      vendor_name in ('CENTURYLINK', 'QWEST') and
      bill_date between &start_date and &end_date and
      a_cfa is not null and 
      circuit_loc = '3'),
  oldMRC AS (
    SELECT DISTINCT
      vendor_name,
      BAN,
      bill_date,
      ec_circuit_id,
      strip_ec_circuit_id,
      a_cfa as old_cfa,
      circuit_loc_addr as old_address
    FROM
      custom_mod_csr
    WHERE
      vendor_name in ('CENTURYLINK', 'QWEST') and
      bill_date between &old_start_date and &old_end_date and
      a_cfa is not null and 
      circuit_loc = '3')
  SELECT
    i.BAN,
    i.ec_circuit_id,
    i.strip_ec_circuit_id,
    nm.new_cfa,
    om.old_cfa,
    nm.new_address,
    om.old_address,
    i.usoc as install_usoc,
    i.bill_amt as install_bill_amt,
    r.usoc as rollover_usoc,
    r.bill_amt as rollover_bill_amt
  FROM
    install i INNER JOIN newMRC nm ON i.strip_ec_circuit_id = nm.strip_ec_circuit_id 
    INNER JOIN oldMRC om ON nm.strip_ec_circuit_id = om.strip_ec_circuit_id 
    LEFT JOIN rollover r ON om.strip_ec_circuit_id = r.strip_ec_circuit_id;

