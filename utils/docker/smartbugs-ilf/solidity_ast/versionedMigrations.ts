import {
    ASTWriter,
    DefaultASTWriterMapping,
    LatestCompilerVersion,
    PrettyFormatter
} from "solc-typed-ast";
import {compile, getAST} from './lib';


let compiled = compile('Migrations.sol');
let ast = getAST(compiled);

const solcVersion = process.argv[2]
const versionRegex = /(?<majorMinor>(.+)\.(.+))(?<patch>\.(.+))/;
let {majorMinor, patch} = solcVersion.match(versionRegex)!.groups!
let literals = ["solidity", majorMinor, patch];
ast[0].vPragmaDirectives[0].literals = literals;

const formatter = new PrettyFormatter(4, 0);
const writer = new ASTWriter(
    DefaultASTWriterMapping,
    formatter,
    solcVersion
);

for (const sourceUnit of ast) {
    console.log("// " + sourceUnit.absolutePath);
    console.log(writer.write(sourceUnit));
}
