import {compile, getAST, getContractsToFuzz} from './lib';


let compiled = compile(process.argv[2])
console.log(compiled.compilerVersion);
const ast = getAST(compiled)
getContractsToFuzz(ast).forEach(contract => console.log(contract.name))
