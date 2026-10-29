'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const {parseCurrentDiagnostic}=require('../app/static/diagnostic-model');
const sample=`29-OCT-26 02.35.30.568000 AM -06:00\n=== 5.16 8.5 cuentas ===\nDEFAULT    PASSWORD_VERIFY_FUNCTION\nNULL\n=== 8.13 respaldo ===\nPIEZAS CIFRADAS\n------ --------\n3 0\n=== 8.9 parches ===\nno rows selected\n=== FIN ===`;
test('extracts counts and profile from diagnostic capture',()=>{
 const d=parseCurrentDiagnostic(sample);assert.equal(d.pieces,3);assert.equal(d.encrypted,0);assert.equal(d.verifier,'NULL');assert.equal(d.patchEmpty,true);assert.match(d.captured,/29-OCT-26/);
});
test('missing or malformed measurements remain unknown',()=>{
 const d=parseCurrentDiagnostic('=== 5.16 accounts ===\nDEFAULT PASSWORD_VERIFY_FUNCTION\nNULL\n=== 8.13 backup ===\nempty\n=== 8.9 patch ===\npatch entries\n=== FIN ===');
 assert.equal(d.pieces,null);assert.equal(d.encrypted,null);assert.equal(d.patchEmpty,false);assert.equal(parseCurrentDiagnostic(null).valid,false);
});
