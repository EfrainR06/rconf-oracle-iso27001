'use strict';
const CASE_PROBES=[['RAW_SELECT','Tabla base protegida'],['MASKED_SELECT','Vista enmascarada disponible'],['DIRECT_UPDATE','UPDATE directo bloqueado']];
function parseCaseCapture(content,phase){
 const fail=error=>({valid:false,error});
 if(/SP2-0640|ORA-01017|PENDIENTE\s*-\s*NO EJECUTADO/i.test(content))return fail('La salida contiene una sesión desconectada o una plantilla pendiente.');
 const lines=content.split(/\r?\n/).map(x=>x.trim()).filter(x=>x.startsWith('RCONF_CASE|')).map(x=>x.split('|'));
 const of=kind=>lines.filter(x=>x[1]===kind);
 const context=of('CONTEXT'),time=of('TIME'),run=of('RUN'),end=of('END'),tests=of('TEST');
 if(context.length!==1||time.length!==1||run.length!==1||end.length!==1||tests.length!==3)return fail('Faltan marcadores únicos de contexto, fecha, ejecución, tres pruebas o cierre. Usá 14/16 del caso aislado.');
 if(lines.some(x=>x[2]!==phase))return fail('El TXT no corresponde a esta etapa.');
 if(context[0][3]!=='RCONF_CASE_APP'||context[0][4]!=='XEPDB1'||end[0][3]!=='3')return fail('Cuenta, PDB o cierre de captura no corresponden al caso.');
 if(!Number.isFinite(Date.parse(time[0][3]))||!/^[A-F0-9]{32}$/i.test(run[0][3]||''))return fail('Fecha o identificador de ejecución no válido.');
 const results=[];
 for(const [id,label]of CASE_PROBES){const rows=tests.filter(t=>t[3]===id);if(rows.length!==1)return fail('Pruebas duplicadas o incompletas.');const row=rows[0],outcome=row[4],code=Number(row[5]);let status='revisar';
  if(id==='MASKED_SELECT'){if(outcome==='MASKED'&&code===0)status='satisfactoria';else if(outcome==='DENIED'&&[942,1031].includes(code)||outcome==='UNEXPECTED'&&code===0)status='fallo'}
  else{if(outcome==='DENIED'&&[942,1031].includes(code))status='satisfactoria';else if(outcome==='ALLOWED'&&code===0)status='fallo'}
  results.push({id,label,outcome,code,status});
 }
 return {valid:true,phase,account:context[0][3],pdb:context[0][4],time:time[0][3],run:run[0][3],results,passed:results.filter(x=>x.status==='satisfactoria').length};
}
function compareCaseCaptures(before,after){if(!before?.valid||!after?.valid)return {comparable:false,error:'Se necesitan dos capturas válidas.'};if(before.run===after.run)return {comparable:false,error:'La ejecución de antes y después debe ser distinta.'};if(Date.parse(after.time)<Date.parse(before.time))return {comparable:false,error:'La captura posterior tiene una fecha anterior al diagnóstico.'};return {comparable:true,delta:after.passed-before.passed};}
if(typeof module!=='undefined')module.exports={parseCaseCapture,compareCaseCaptures,CASE_PROBES};
