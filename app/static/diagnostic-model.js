'use strict';
// Interpreta únicamente la salida conocida de 22_diagnostico_actual.sql.
// Nunca sustituye una revisión del archivo original ni una evaluación global.
function parseCurrentDiagnostic(content){
 if(typeof content!=='string')return {valid:false};
 const section=heading=>{const start=content.indexOf(heading);if(start<0)return '';const end=content.indexOf('=== ',start+4);return content.slice(start,end<0?undefined:end)};
 const backups=section('=== 8.13');
 const counts=backups.match(/PIEZAS\s+CIFRADAS\s*[-\s]+?\s*(\d+)\s+(\d+)/i);
 const profiles=section('=== 5.16');
 const verifier=profiles.match(/\bDEFAULT\s+PASSWORD_VERIFY_FUNCTION\s+(\S+)/i);
 const patch=section('=== 8.9');
 const context=content.match(/\b(\d{2}-[A-Z]{3}-\d{2})\s+([\d.:]+\s+[AP]M\s+[+-]\d{2}:\d{2})/i);
 return {valid:Boolean(backups&&profiles),pieces:counts?Number(counts[1]):null,
  encrypted:counts?Number(counts[2]):null,verifier:verifier?verifier[1]:null,
  patchEmpty:patch? /\bno rows selected\b/i.test(patch):null,
  captured:context?context[0]:null};
}
if(typeof module!=='undefined')module.exports={parseCurrentDiagnostic};
