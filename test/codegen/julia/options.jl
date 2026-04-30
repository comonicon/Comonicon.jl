Comonicon.moduleComonicon. Comonicon.TestLeafOptionsComonicon.

Comonicon.usingComonicon. Comonicon.ComoniconComonicon..ASTComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon..JuliaExprComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon..JuliaExprComonicon.: Comonicon.emitComonicon., Comonicon.emit_bodyComonicon., Comonicon.emit_norm_bodyComonicon., Comonicon.emit_dash_bodyComonicon.
Comonicon.usingComonicon. Comonicon.TestComonicon.

Comonicon.constComonicon. Comonicon.test_argsComonicon. = Comonicon.RefComonicon.{Comonicon.VectorComonicon.{Comonicon.AnyComonicon.}}()
Comonicon.constComonicon. Comonicon.test_kwargsComonicon. = Comonicon.RefComonicon.{Comonicon.DictComonicon.{Comonicon.SymbolComonicon.,Comonicon.AnyComonicon.}}()

Comonicon.functionComonicon. Comonicon.fooComonicon.(; Comonicon.kwargsComonicon....)
    Comonicon.test_kwargsComonicon.[] = Comonicon.DictComonicon.{Comonicon.SymbolComonicon.,Comonicon.AnyComonicon.}(Comonicon.kwargsComonicon.)
Comonicon.endComonicon.

Comonicon.cmdComonicon. = Comonicon.EntryComonicon.(;
    Comonicon.versionComonicon. = Comonicon.vComonicon."Comonicon.1Comonicon..Comonicon.1Comonicon..Comonicon.0Comonicon.",
    Comonicon.rootComonicon. = Comonicon.LeafCommandComonicon.(;
        Comonicon.fnComonicon. = Comonicon.fooComonicon.,
        Comonicon.nameComonicon. = "Comonicon.leafComonicon.",
        Comonicon.optionsComonicon. = Comonicon.DictComonicon.(
            "Comonicon.optionComonicon.-Comonicon.aComonicon." => Comonicon.OptionComonicon.(; Comonicon.symComonicon. = :Comonicon.option_aComonicon., Comonicon.hintComonicon. = "Comonicon.intComonicon.", Comonicon.typeComonicon. = Comonicon.IntComonicon., Comonicon.shortComonicon. = Comonicon.trueComonicon.),
            "Comonicon.optionComonicon.-Comonicon.bComonicon." => Comonicon.OptionComonicon.(; Comonicon.symComonicon. = :Comonicon.option_bComonicon., Comonicon.hintComonicon. = "Comonicon.float64Comonicon.", Comonicon.typeComonicon. = Comonicon.Float64Comonicon.),
        ),
        Comonicon.flagsComonicon. = Comonicon.DictComonicon.(
            "Comonicon.flagComonicon.-Comonicon.aComonicon." => Comonicon.FlagComonicon.(; Comonicon.symComonicon. = :Comonicon.flag_aComonicon., Comonicon.shortComonicon. = Comonicon.trueComonicon.),
            "Comonicon.flagComonicon.-Comonicon.bComonicon." => Comonicon.FlagComonicon.(; Comonicon.symComonicon. = :Comonicon.flag_bComonicon.),
        ),
    ),
)

Comonicon.evalComonicon.(Comonicon.emitComonicon.(Comonicon.cmdComonicon.))

@Comonicon.testsetComonicon. "Comonicon.testComonicon. Comonicon.leafComonicon. Comonicon.optionsComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["--Comonicon.optionComonicon.-Comonicon.aComonicon.=Comonicon.3Comonicon.", "--Comonicon.optionComonicon.-Comonicon.bComonicon.", "Comonicon.1Comonicon..Comonicon.2Comonicon.", "-Comonicon.fComonicon.", "--Comonicon.flagComonicon.-Comonicon.bComonicon."]) == Comonicon.0Comonicon.
    @Comonicon.testComonicon. Comonicon.test_kwargsComonicon.[] ==
          Comonicon.DictComonicon.{Comonicon.SymbolComonicon.,Comonicon.AnyComonicon.}(:Comonicon.option_aComonicon. => Comonicon.3Comonicon., :Comonicon.option_bComonicon. => Comonicon.1Comonicon..Comonicon.2Comonicon., :Comonicon.flag_aComonicon. => Comonicon.trueComonicon., :Comonicon.flag_bComonicon. => Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["-Comonicon.oComonicon.=Comonicon.3Comonicon.", "--Comonicon.optionComonicon.-Comonicon.bComonicon.", "Comonicon.1Comonicon..Comonicon.2Comonicon.", "-Comonicon.fComonicon.", "--Comonicon.flagComonicon.-Comonicon.bComonicon."]) == Comonicon.0Comonicon.
    @Comonicon.testComonicon. Comonicon.test_kwargsComonicon.[] ==
          Comonicon.DictComonicon.{Comonicon.SymbolComonicon.,Comonicon.AnyComonicon.}(:Comonicon.option_aComonicon. => Comonicon.3Comonicon., :Comonicon.option_bComonicon. => Comonicon.1Comonicon..Comonicon.2Comonicon., :Comonicon.flag_aComonicon. => Comonicon.trueComonicon., :Comonicon.flag_bComonicon. => Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["-Comonicon.o3Comonicon.", "--Comonicon.optionComonicon.-Comonicon.bComonicon.", "Comonicon.1Comonicon..Comonicon.2Comonicon.", "-Comonicon.fComonicon.", "--Comonicon.flagComonicon.-Comonicon.bComonicon."]) == Comonicon.0Comonicon.
    @Comonicon.testComonicon. Comonicon.test_kwargsComonicon.[] ==
          Comonicon.DictComonicon.{Comonicon.SymbolComonicon.,Comonicon.AnyComonicon.}(:Comonicon.option_aComonicon. => Comonicon.3Comonicon., :Comonicon.option_bComonicon. => Comonicon.1Comonicon..Comonicon.2Comonicon., :Comonicon.flag_aComonicon. => Comonicon.trueComonicon., :Comonicon.flag_bComonicon. => Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["--Comonicon.optionComonicon.-Comonicon.aComonicon.", "--Comonicon.optionComonicon.-Comonicon.bComonicon.", "Comonicon.1Comonicon..Comonicon.2Comonicon.", "-Comonicon.fComonicon.", "--Comonicon.flagComonicon.-Comonicon.bComonicon."]) == Comonicon.1Comonicon.
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["-Comonicon.oComonicon.", "--Comonicon.optionComonicon.-Comonicon.bComonicon.", "Comonicon.1Comonicon..Comonicon.2Comonicon.", "-Comonicon.fComonicon.", "--Comonicon.flagComonicon.-Comonicon.bComonicon."]) == Comonicon.1Comonicon.
Comonicon.endComonicon.


Comonicon.cmdComonicon. = Comonicon.EntryComonicon.(;
    Comonicon.versionComonicon. = Comonicon.vComonicon."Comonicon.1Comonicon..Comonicon.1Comonicon..Comonicon.0Comonicon.",
    Comonicon.rootComonicon. = Comonicon.LeafCommandComonicon.(;
        Comonicon.fnComonicon. = Comonicon.fooComonicon.,
        Comonicon.nameComonicon. = "Comonicon.leafComonicon.",
        Comonicon.optionsComonicon. = Comonicon.DictComonicon.(
            "Comonicon.optionComonicon.-Comonicon.aComonicon." => Comonicon.OptionComonicon.(; Comonicon.symComonicon. = :Comonicon.option_aComonicon., Comonicon.hintComonicon. = "Comonicon.strComonicon.", Comonicon.typeComonicon. = Comonicon.StringComonicon., Comonicon.shortComonicon. = Comonicon.trueComonicon.),
            "Comonicon.optionComonicon.-Comonicon.bComonicon." => Comonicon.OptionComonicon.(; Comonicon.symComonicon. = :Comonicon.option_bComonicon., Comonicon.hintComonicon. = "Comonicon.float64Comonicon.", Comonicon.typeComonicon. = Comonicon.Float64Comonicon.),
        ),
        Comonicon.flagsComonicon. = Comonicon.DictComonicon.(
            "Comonicon.flagComonicon.-Comonicon.aComonicon." => Comonicon.FlagComonicon.(; Comonicon.symComonicon. = :Comonicon.flag_aComonicon., Comonicon.shortComonicon. = Comonicon.trueComonicon.),
            "Comonicon.flagComonicon.-Comonicon.bComonicon." => Comonicon.FlagComonicon.(; Comonicon.symComonicon. = :Comonicon.flag_bComonicon.),
        ),
    ),
)

Comonicon.evalComonicon.(Comonicon.emitComonicon.(Comonicon.cmdComonicon.))

Comonicon.endComonicon.

Comonicon.moduleComonicon. Comonicon.TestStringTypeComonicon.
Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.buildComonicon.(Comonicon.nameComonicon.::Comonicon.StringComonicon.; Comonicon.targetComonicon.::Comonicon.StringComonicon. = Comonicon.nothingComonicon.)
    Comonicon.ifComonicon. Comonicon.targetComonicon. == "Comonicon.notebookComonicon."
    Comonicon.elseifComonicon. Comonicon.targetComonicon. == "Comonicon.markdownComonicon."
    Comonicon.elseComonicon.
    Comonicon.endComonicon.
Comonicon.endComonicon.

@Comonicon.mainComonicon.

@Comonicon.testsetComonicon. "Comonicon.testComonicon. Comonicon.StringComonicon. Comonicon.typeComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.command_mainComonicon.(["Comonicon.buildComonicon.", "Comonicon.testComonicon.", "--Comonicon.targetComonicon.=Comonicon.aaaaComonicon."]) == Comonicon.0Comonicon.
Comonicon.endComonicon.
Comonicon.endComonicon.

Comonicon.moduleComonicon. Comonicon.TestRequireOptionsComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

"""
# Comonicon.OptionsComonicon.

- `--Comonicon.nameComonicon.=<Comonicon.stringComonicon.>`: Comonicon.nameComonicon.
"""
@Comonicon.mainComonicon. Comonicon.functionComonicon. Comonicon.runComonicon.(; Comonicon.nameComonicon.::Comonicon.StringComonicon., Comonicon.shotsComonicon.::Comonicon.IntComonicon.)
    @Comonicon.testComonicon. Comonicon.nameComonicon. == "Comonicon.testComonicon."
    @Comonicon.testComonicon. Comonicon.shotsComonicon. == Comonicon.2Comonicon.
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.TestRequireOptionsComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.TestRequireOptionsComonicon..Comonicon.command_mainComonicon.(["--Comonicon.nameComonicon.=Comonicon.testComonicon."]) == Comonicon.1Comonicon.
    @Comonicon.testComonicon. Comonicon.TestRequireOptionsComonicon..Comonicon.command_mainComonicon.(["--Comonicon.nameComonicon.=Comonicon.testComonicon.", "--Comonicon.shotsComonicon.=Comonicon.2Comonicon."]) == Comonicon.0Comonicon.
Comonicon.endComonicon.

Comonicon.endComonicon.

Comonicon.moduleComonicon. Comonicon.TestShortOptionsComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

"""
# Comonicon.OptionsComonicon.

- `-Comonicon.eComonicon., --Comonicon.exampleComonicon. <Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon..
"""
@Comonicon.mainComonicon. Comonicon.functionComonicon. Comonicon.runComonicon.(; Comonicon.exampleComonicon.::Comonicon.StringComonicon.)
    @Comonicon.testComonicon. Comonicon.exampleComonicon. == "Comonicon.demoComonicon."
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.TestShortOptionsComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.TestShortOptionsComonicon..Comonicon.command_mainComonicon.(["-Comonicon.eComonicon.", "Comonicon.demoComonicon."]) == Comonicon.0Comonicon.
Comonicon.endComonicon.

Comonicon.endComonicon.
