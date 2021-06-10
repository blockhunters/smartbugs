import { CompileFailedError, CompileResult, compileSol, ContractKind, ASTReader, SourceUnit } from "solc-typed-ast";


export const compile = (path:string) => {
    try {
        return compileSol(path, "auto", []);
    } catch (e) {
        if (e instanceof CompileFailedError) {
            console.error("Compile errors encountered:");

            for (const failure of e.failures) {
                console.error(`SolcJS ${failure.compilerVersion}:`);

                for (const error of failure.errors) {
                    console.error(error);
                }
            }
        } else {
            console.error(e.message);
        }
        process.exit(1)
    }
}


export const getAST = (compiled: CompileResult) => new ASTReader().read(compiled.data);


export const getContractsToFuzz = (ast: SourceUnit[]) => {
    let subclasses = new Set();
    ast[0].vContracts.forEach(contract => {
        let baseContracts = contract.linearizedBaseContracts
        // Drop first element - id of the contract itself
        baseContracts.shift();
        baseContracts.forEach(subclasses.add, subclasses);
    });
    let superClasses = ast[0].vContracts.filter(contract => !subclasses.has(contract.id));
    return superClasses.filter(contract => contract.kind == ContractKind.Contract && !contract.abstract)
}
