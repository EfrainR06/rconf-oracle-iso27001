'use strict';
const MATURITY_STEPS=['ANTES','R01','R02','R03','R04','R05','TDE','RMAN','Red','DESPUÉS'];
const MATURITY_BLOCKS=['R01','R02','R03','R04','R05','TDE','RMAN','Red'];
const CONTROL_BLOCKS={'5.16':'R01','8.9':'R01','5.15':'R02','5.18':'R02','8.2':'R02','5.17':'R03','8.5':'R03','8.28':'R03','5.12':'R04','8.3':'R04','8.11':'R04','5.33':'R05','8.10':'R05','8.12':'R05','8.15':'R05','8.16':'R05','8.24':'TDE','8.13':'RMAN','5.23':'Red','8.20':'Red'};
const MATURITY_RISKS=[
 {id:'R-CONF-01',title:'Privilegios excesivos',controls:['5.15','5.18','8.2','8.3']},
 {id:'R-CONF-02',title:'Cuentas sin necesidad vigente',controls:['5.16','5.18','8.5','8.9']},
 {id:'R-CONF-03',title:'Credenciales expuestas',controls:['5.17','8.5','8.28']},
 {id:'R-CONF-04',title:'Canal de conexión desprotegido',controls:['5.23','8.20','8.24']},
 {id:'R-CONF-05',title:'Lectura de datos innecesarios',controls:['5.12','8.3','8.11']},
 {id:'R-CONF-06',title:'Exportación y fuga',controls:['5.12','5.33','8.10','8.12','8.28']},
 {id:'R-CONF-07',title:'Accesos sin trazabilidad',controls:['5.33','8.15','8.16']},
 {id:'R-CONF-08',title:'Respaldos accesibles',controls:['5.15','8.13','8.24']}
];
function validMaturityRow(r){return r&&r.reviewed===true&&Number.isInteger(r.before)&&r.before>=0&&r.before<=4&&Number.isInteger(r.after)&&r.after>=0&&r.after<=4&&typeof r.beforeRef==='string'&&r.beforeRef.trim()&&typeof r.afterRef==='string'&&r.afterRef.trim()&&MATURITY_BLOCKS.includes(r.block)}
function maturityPoints(ids,assessment){if(!ids.length||!ids.every(id=>validMaturityRow(assessment[id])))return MATURITY_STEPS.map(()=>null);return MATURITY_STEPS.map((step,index)=>ids.reduce((sum,id)=>{const r=assessment[id],after=index===9||(index>0&&MATURITY_BLOCKS.indexOf(r.block)<index);return sum+(after?r.after:r.before)},0)/ids.length)}
function maturityDataset(ids,assessment,riskData=MATURITY_RISKS){return [...riskData.map(r=>({...r,values:maturityPoints(r.controls,assessment)})),{id:'Promedio',title:'Promedio de los '+ids.length+' controles del catálogo',controls:ids,values:maturityPoints(ids,assessment)}]}
function cleanMaturityImport(value,allowed){const clean=Object.create(null);if(value==null)return clean;if(typeof value!=='object'||Array.isArray(value))throw Error('La matriz de madurez no es válida.');for(const [id,r]of Object.entries(value)){if(!allowed.has(id)||!r||typeof r!=='object')throw Error('Control de madurez no publicado.');for(const key of ['before','after'])if(r[key]!==null&&r[key]!==undefined&&(!Number.isInteger(r[key])||r[key]<0||r[key]>4))throw Error('Madurez fuera de 0–4.');if(!MATURITY_BLOCKS.includes(r.block)||typeof r.beforeRef!=='string'||r.beforeRef.length>300||typeof r.afterRef!=='string'||r.afterRef.length>300||typeof r.reviewed!=='boolean')throw Error('Referencias o bloque de madurez no válidos.');for(const k of ['beforeStatus','afterStatus'])if(r[k]!==undefined&&!['','Cumple','Parcial','No cumple'].includes(r[k]))throw Error('Estado de control no válido.');clean[id]={before:r.before??null,after:r.after??null,beforeRef:r.beforeRef,afterRef:r.afterRef,block:r.block,reviewed:r.reviewed,beforeStatus:r.beforeStatus||'',afterStatus:r.afterStatus||''}}return clean}
if(typeof module!=='undefined')module.exports={maturityPoints,maturityDataset,validMaturityRow,cleanMaturityImport,MATURITY_STEPS};
