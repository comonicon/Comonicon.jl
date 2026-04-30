Comonicon.moduleComonicon. Comonicon.TestMarkdownComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.MarkdownComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon..ASTComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.:
    Comonicon.JLArgumentComonicon.,
    Comonicon.JLOptionComonicon.,
    Comonicon.JLFlagComonicon.,
    Comonicon.JLMDComonicon.,
    Comonicon.JLMDFlagComonicon.,
    Comonicon.JLMDOptionComonicon.,
    Comonicon.castComonicon.,
    Comonicon.cast_argsComonicon.,
    Comonicon.cast_flagsComonicon.,
    Comonicon.cast_optionsComonicon.,
    Comonicon.default_nameComonicon.,
    Comonicon.get_versionComonicon.,
    Comonicon.split_leaf_commandComonicon.,
    Comonicon.split_docstringComonicon.,
    Comonicon.read_argumentsComonicon.,
    Comonicon.read_introComonicon.,
    Comonicon.read_descriptionComonicon.,
    Comonicon.read_optionsComonicon.,
    Comonicon.read_flagsComonicon.,
    Comonicon.split_hintComonicon.,
    Comonicon.split_optionComonicon.

@Comonicon.testsetComonicon. "Comonicon.read_argumentsComonicon." Comonicon.beginComonicon.
    Comonicon.docComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
        Comonicon.commandComonicon. <Comonicon.argsComonicon.>

    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.IntroComonicon.

    Comonicon.asdmwdsComonicon. Comonicon.dasklsamComonicon. Comonicon.xasdklqmComonicon. Comonicon.dasdmComonicon., Comonicon.qwdjiolkasjdsaComonicon.
    Comonicon.dasklmdasComonicon. Comonicon.weqwlkjmdasComonicon. Comonicon.kljnsadlksadComonicon. Comonicon.qwlkdnasdComonicon.
    Comonicon.dasklmdlqwoiComonicon., Comonicon.dasdasklmdComonicon. Comonicon.qwComonicon.,Comonicon.asdComonicon.. Comonicon.dasdjklnmldqwComonicon..

    # Comonicon.ArgsComonicon.

    - `Comonicon.arg1Comonicon.`: Comonicon.argumentComonicon. Comonicon.1Comonicon..
    - `Comonicon.arg2Comonicon.`: Comonicon.argumentComonicon. Comonicon.2Comonicon..
    - `Comonicon.arg3Comonicon.`: Comonicon.argumentComonicon. Comonicon.3Comonicon..
    - `Comonicon.arg4Comonicon.`: Comonicon.argumentComonicon. Comonicon.4Comonicon..
    """)

    @Comonicon.testComonicon. Comonicon.read_descriptionComonicon.(Comonicon.docComonicon.) == "Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon.."
    @Comonicon.testComonicon. Comonicon.read_introComonicon.(Comonicon.docComonicon.) ==
          "Comonicon.asdmwdsComonicon. Comonicon.dasklsamComonicon. Comonicon.xasdklqmComonicon. Comonicon.dasdmComonicon., Comonicon.qwdjiolkasjdsaComonicon. " *
          "Comonicon.dasklmdasComonicon. Comonicon.weqwlkjmdasComonicon. Comonicon.kljnsadlksadComonicon. Comonicon.qwlkdnasdComonicon. " *
          "Comonicon.dasklmdlqwoiComonicon., Comonicon.dasdasklmdComonicon. Comonicon.qwComonicon.,Comonicon.asdComonicon.. Comonicon.dasdjklnmldqwComonicon.."

    Comonicon.argsComonicon. = Comonicon.read_argumentsComonicon.(Comonicon.docComonicon.)
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg1Comonicon."] == "Comonicon.argumentComonicon. Comonicon.1Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg2Comonicon."] == "Comonicon.argumentComonicon. Comonicon.2Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg3Comonicon."] == "Comonicon.argumentComonicon. Comonicon.3Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg4Comonicon."] == "Comonicon.argumentComonicon. Comonicon.4Comonicon.."

    Comonicon.docComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.ArgumentsComonicon.

    - `Comonicon.arg1Comonicon.`: Comonicon.argumentComonicon. Comonicon.1Comonicon..
    - `Comonicon.arg2Comonicon.`: Comonicon.argumentComonicon. Comonicon.2Comonicon..
    - `Comonicon.arg3Comonicon.`: Comonicon.argumentComonicon. Comonicon.3Comonicon..
    - `Comonicon.arg4Comonicon.`: Comonicon.argumentComonicon. Comonicon.4Comonicon..
    """)

    @Comonicon.testComonicon. Comonicon.read_descriptionComonicon.(Comonicon.docComonicon.) == "Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon.."

    Comonicon.argsComonicon. = Comonicon.read_argumentsComonicon.(Comonicon.docComonicon.)
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg1Comonicon."] == "Comonicon.argumentComonicon. Comonicon.1Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg2Comonicon."] == "Comonicon.argumentComonicon. Comonicon.2Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg3Comonicon."] == "Comonicon.argumentComonicon. Comonicon.3Comonicon.."
    @Comonicon.testComonicon. Comonicon.argsComonicon.["Comonicon.arg4Comonicon."] == "Comonicon.argumentComonicon. Comonicon.4Comonicon.."
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.split_hintComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.longComonicon.") == ("Comonicon.longComonicon.", Comonicon.nothingComonicon.)
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.longComonicon. <Comonicon.valueComonicon.>") == ("Comonicon.longComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.longComonicon.=<Comonicon.valueComonicon.>") == ("Comonicon.longComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.sComonicon.") == ("Comonicon.sComonicon.", Comonicon.nothingComonicon.)
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.sComonicon.=<Comonicon.valueComonicon.>") == ("Comonicon.sComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_hintComonicon.("Comonicon.sComonicon. <Comonicon.valueComonicon.>") == ("Comonicon.sComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_hintComonicon.("Comonicon.sComonicon.=Comonicon.sComonicon.")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_hintComonicon.("Comonicon.sComonicon.=Comonicon.sComonicon.=Comonicon.sComonicon.")
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.split_optionComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.longComonicon.") == ("Comonicon.longComonicon.", Comonicon.nothingComonicon., Comonicon.nothingComonicon.)
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.longComonicon. <Comonicon.valueComonicon.>") == ("Comonicon.longComonicon.", Comonicon.nothingComonicon., "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.longComonicon.=<Comonicon.valueComonicon.>") == ("Comonicon.longComonicon.", Comonicon.nothingComonicon., "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.sComonicon.") == ("Comonicon.shortComonicon.", "Comonicon.sComonicon.", Comonicon.nothingComonicon.)
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.sComonicon. <Comonicon.valueComonicon.>") == ("Comonicon.shortComonicon.", "Comonicon.sComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.testComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.sComonicon.=<Comonicon.valueComonicon.>") == ("Comonicon.shortComonicon.", "Comonicon.sComonicon.", "Comonicon.valueComonicon.")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.ssComonicon., -Comonicon.stComonicon.")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.ssComonicon.")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.ssComonicon.=<Comonicon.valueComonicon.>")
    @Comonicon.test_throwsComonicon. Comonicon.MetaComonicon..Comonicon.ParseErrorComonicon. Comonicon.split_optionComonicon.("--Comonicon.shortComonicon., -Comonicon.tComonicon.=<Comonicon.valueComonicon.>")
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.read_optionsComonicon." Comonicon.beginComonicon.
    Comonicon.docComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.OptionsComonicon.

    - `--Comonicon.shortComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.spaceComonicon., -Comonicon.sComonicon. <Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.assignComonicon., -Comonicon.sComonicon.=<Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.-Comonicon.spaceComonicon. <Comonicon.valueComonicon.>`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.-Comonicon.assignComonicon.=<Comonicon.valueComonicon.>`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.short_underscoreComonicon., -Comonicon.sComonicon. <Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.withComonicon. Comonicon.underscoreComonicon..
    """)

    Comonicon.optionsComonicon. = Comonicon.read_optionsComonicon.(Comonicon.docComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.shortComonicon."] == Comonicon.JLMDOptionComonicon.(Comonicon.nothingComonicon., "Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.shortComonicon.-Comonicon.spaceComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.shortComonicon.-Comonicon.assignComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.longComonicon."] == Comonicon.JLMDOptionComonicon.(Comonicon.nothingComonicon., "Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..", Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.longComonicon.-Comonicon.spaceComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..", Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.longComonicon.-Comonicon.assignComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..", Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.shortComonicon.-Comonicon.underscoreComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.withComonicon. Comonicon.underscoreComonicon..", Comonicon.trueComonicon.)
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.read_flagsComonicon." Comonicon.beginComonicon.
    Comonicon.docComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.FlagsComonicon.

    - `--Comonicon.shortComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.flagComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.spaceComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..
    - `--Comonicon.longComonicon.`: Comonicon.longComonicon. Comonicon.flagComonicon..
    - `--Comonicon.longComonicon.-Comonicon.spaceComonicon.`: Comonicon.longComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..
    """)

    Comonicon.flagsComonicon. = Comonicon.read_flagsComonicon.(Comonicon.docComonicon.)
    @Comonicon.testComonicon. Comonicon.flagsComonicon.["Comonicon.shortComonicon."] == Comonicon.JLMDFlagComonicon.("Comonicon.shortComonicon. Comonicon.flagComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.flagsComonicon.["Comonicon.shortComonicon.-Comonicon.spaceComonicon."] == Comonicon.JLMDFlagComonicon.("Comonicon.shortComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.flagsComonicon.["Comonicon.longComonicon."] == Comonicon.JLMDFlagComonicon.("Comonicon.longComonicon. Comonicon.flagComonicon..", Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.flagsComonicon.["Comonicon.longComonicon.-Comonicon.spaceComonicon."] == Comonicon.JLMDFlagComonicon.("Comonicon.longComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..", Comonicon.falseComonicon.)
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.split_docstringComonicon." Comonicon.beginComonicon.
    Comonicon.contentComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.ArgsComonicon.

    - `Comonicon.arg1Comonicon.`: Comonicon.argumentComonicon. Comonicon.1Comonicon..
    - `Comonicon.arg2Comonicon.`: Comonicon.argumentComonicon. Comonicon.2Comonicon..
    - `Comonicon.arg3Comonicon.`: Comonicon.argumentComonicon. Comonicon.3Comonicon..
    - `Comonicon.arg4Comonicon.`: Comonicon.argumentComonicon. Comonicon.4Comonicon..

    # Comonicon.OptionsComonicon.

    - `--Comonicon.shortComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.spaceComonicon., -Comonicon.sComonicon. <Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.assignComonicon., -Comonicon.sComonicon.=<Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.-Comonicon.spaceComonicon. <Comonicon.valueComonicon.>`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.longComonicon.-Comonicon.assignComonicon.=<Comonicon.valueComonicon.>`: Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.givenComonicon. Comonicon.hintComonicon..
    - `--Comonicon.short_underscoreComonicon., -Comonicon.sComonicon. <Comonicon.valueComonicon.>`: Comonicon.shortComonicon. Comonicon.optionComonicon. Comonicon.withComonicon. Comonicon.underscoreComonicon..

    # Comonicon.FlagsComonicon.

    - `--Comonicon.shortComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.flagComonicon..
    - `--Comonicon.shortComonicon.-Comonicon.spaceComonicon., -Comonicon.sComonicon.`: Comonicon.shortComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..
    - `--Comonicon.longComonicon.`: Comonicon.longComonicon. Comonicon.flagComonicon..
    - `--Comonicon.longComonicon.-Comonicon.spaceComonicon.`: Comonicon.longComonicon. Comonicon.flagComonicon. Comonicon.withComonicon. Comonicon.dashComonicon..
    """)

    Comonicon.docComonicon. = Comonicon.split_docstringComonicon.(Comonicon.contentComonicon.)
    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.descComonicon. == "Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon.."
    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.argumentsComonicon.["Comonicon.arg1Comonicon."] == "Comonicon.argumentComonicon. Comonicon.1Comonicon.."
    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.flagsComonicon.["Comonicon.longComonicon."] == Comonicon.JLMDFlagComonicon.("Comonicon.longComonicon. Comonicon.flagComonicon..", Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.optionsComonicon.["Comonicon.longComonicon."] == Comonicon.JLMDOptionComonicon.(Comonicon.nothingComonicon., "Comonicon.longComonicon. Comonicon.optionComonicon. Comonicon.usingComonicon. Comonicon.defaultComonicon. Comonicon.hintComonicon..", Comonicon.falseComonicon.)

    Comonicon.args_sortedComonicon. = ["Comonicon.arg1Comonicon.", "Comonicon.arg2Comonicon.", "Comonicon.arg3Comonicon.", "Comonicon.arg4Comonicon."]
    @Comonicon.testComonicon. Comonicon.allComonicon.(Comonicon.keysComonicon.(Comonicon.docComonicon..Comonicon.argumentsComonicon.) .== Comonicon.args_sortedComonicon.)

    Comonicon.opts_sortedComonicon. = [
        "Comonicon.shortComonicon.",
        "Comonicon.shortComonicon.-Comonicon.spaceComonicon.",
        "Comonicon.shortComonicon.-Comonicon.assignComonicon.",
        "Comonicon.longComonicon.",
        "Comonicon.longComonicon.-Comonicon.spaceComonicon.",
        "Comonicon.longComonicon.-Comonicon.assignComonicon.",
        "Comonicon.shortComonicon.-Comonicon.underscoreComonicon.",
    ]
    @Comonicon.testComonicon. Comonicon.allComonicon.(Comonicon.keysComonicon.(Comonicon.docComonicon..Comonicon.optionsComonicon.) .== Comonicon.opts_sortedComonicon.)

    Comonicon.flags_sortedComonicon. = ["Comonicon.shortComonicon.", "Comonicon.shortComonicon.-Comonicon.spaceComonicon.", "Comonicon.longComonicon.", "Comonicon.longComonicon.-Comonicon.spaceComonicon."]
    @Comonicon.testComonicon. Comonicon.allComonicon.(Comonicon.keysComonicon.(Comonicon.docComonicon..Comonicon.flagsComonicon.) .== Comonicon.flags_sortedComonicon.)
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.reverseComonicon. Comonicon.orderComonicon." Comonicon.beginComonicon.
    Comonicon.contentComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.OptionsComonicon.

    - `-Comonicon.oComonicon., --Comonicon.optionComonicon.=<Comonicon.valueComonicon.>`: Comonicon.someComonicon. Comonicon.randomComonicon. Comonicon.optionComonicon..
    - `-Comonicon.oComonicon.,--Comonicon.option_spaceComonicon.=<Comonicon.valueComonicon.>`: Comonicon.someComonicon. Comonicon.randomComonicon. Comonicon.optionComonicon..
    """)

    Comonicon.docComonicon. = Comonicon.split_docstringComonicon.(Comonicon.contentComonicon.)

    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.optionsComonicon.["Comonicon.optionComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.someComonicon. Comonicon.randomComonicon. Comonicon.optionComonicon..", Comonicon.trueComonicon.)
    @Comonicon.testComonicon. Comonicon.docComonicon..Comonicon.optionsComonicon.["Comonicon.optionComonicon.-Comonicon.spaceComonicon."] == Comonicon.JLMDOptionComonicon.("Comonicon.valueComonicon.", "Comonicon.someComonicon. Comonicon.randomComonicon. Comonicon.optionComonicon..", Comonicon.trueComonicon.)

    Comonicon.contentComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.descriptionComonicon. Comonicon.ofComonicon. Comonicon.theComonicon. Comonicon.commandComonicon..

    # Comonicon.OptionsComonicon.

    - `-Comonicon.oComonicon., Comonicon.optionComonicon.=<Comonicon.valueComonicon.>`: Comonicon.someComonicon. Comonicon.randomComonicon. Comonicon.optionComonicon..
    """)

    @Comonicon.test_throwsComonicon. Comonicon.ErrorExceptionComonicon. Comonicon.split_docstringComonicon.(Comonicon.contentComonicon.)
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.hintComonicon. Comonicon.withComonicon. Comonicon.spaceComonicon." Comonicon.beginComonicon.
    Comonicon.docComonicon. = Comonicon.MarkdownComonicon..Comonicon.parseComonicon.("""
    Comonicon.releaseComonicon. Comonicon.aComonicon. Comonicon.packageComonicon..

    # Comonicon.ArgumentsComonicon.

    - `Comonicon.version_specComonicon.`: Comonicon.versionComonicon. Comonicon.numberComonicon. Comonicon.youComonicon. Comonicon.wantComonicon. Comonicon.toComonicon. Comonicon.releaseComonicon.. Comonicon.CanComonicon. Comonicon.beComonicon. Comonicon.aComonicon. Comonicon.specificComonicon. Comonicon.versionComonicon., "Comonicon.currentComonicon."
        Comonicon.orComonicon. Comonicon.eitherComonicon. Comonicon.ofComonicon.
    - `Comonicon.pathComonicon.`: Comonicon.pathComonicon. Comonicon.toComonicon. Comonicon.theComonicon. Comonicon.projectComonicon. Comonicon.youComonicon. Comonicon.wantComonicon. Comonicon.toComonicon. Comonicon.releaseComonicon..

    # Comonicon.OptionsComonicon.

    - `-Comonicon.rComonicon.,--Comonicon.registryComonicon. <Comonicon.registryComonicon. Comonicon.nameComonicon.>`: Comonicon.registryComonicon. Comonicon.youComonicon. Comonicon.wantComonicon. Comonicon.toComonicon. Comonicon.registerComonicon. Comonicon.theComonicon. Comonicon.packageComonicon..
        Comonicon.IfComonicon. Comonicon.theComonicon. Comonicon.packageComonicon. Comonicon.hasComonicon. Comonicon.notComonicon. Comonicon.beenComonicon. Comonicon.registeredComonicon., Comonicon.ionComonicon. Comonicon.willComonicon. Comonicon.tryComonicon. Comonicon.toComonicon. Comonicon.registerComonicon.
        Comonicon.theComonicon. Comonicon.packageComonicon. Comonicon.inComonicon. Comonicon.theComonicon. Comonicon.GeneralComonicon. Comonicon.registryComonicon.. Comonicon.OrComonicon. Comonicon.theComonicon. Comonicon.userComonicon. Comonicon.needsComonicon. Comonicon.toComonicon. Comonicon.specifyComonicon.
        Comonicon.theComonicon. Comonicon.registryComonicon. Comonicon.toComonicon. Comonicon.registerComonicon. Comonicon.usingComonicon. Comonicon.thisComonicon. Comonicon.optionComonicon..
    - `-Comonicon.bComonicon., --Comonicon.branchComonicon. <Comonicon.branchComonicon. Comonicon.nameComonicon.>`: Comonicon.branchComonicon. Comonicon.youComonicon. Comonicon.wantComonicon. Comonicon.toComonicon. Comonicon.registerComonicon..
    - `--Comonicon.noteComonicon. <Comonicon.releaseComonicon. Comonicon.noteComonicon.>`: Comonicon.optionalComonicon., Comonicon.releaseComonicon. Comonicon.noteComonicon. Comonicon.youComonicon. Comonicon.wouldComonicon. Comonicon.likeComonicon. Comonicon.toComonicon. Comonicon.specifyComonicon..
    """)

    Comonicon.optionsComonicon. = Comonicon.read_optionsComonicon.(Comonicon.docComonicon.)
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.noteComonicon."].Comonicon.hintComonicon. == "Comonicon.releaseComonicon. Comonicon.noteComonicon."
    @Comonicon.testComonicon. Comonicon.optionsComonicon.["Comonicon.registryComonicon."].Comonicon.hintComonicon. == "Comonicon.registryComonicon. Comonicon.nameComonicon."
Comonicon.endComonicon.

Comonicon.moduleComonicon. Comonicon.TestEmptyDocStringComonicon.
Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

@Comonicon.castComonicon. Comonicon.testComonicon.() = @Comonicon.testComonicon. Comonicon.trueComonicon.

"""
"""
@Comonicon.mainComonicon.

Comonicon.endComonicon. # Comonicon.TestEmptyDocStringComonicon.

@Comonicon.testsetComonicon. "Comonicon.emptyComonicon. Comonicon.docstringComonicon." Comonicon.beginComonicon.
    Comonicon.TestEmptyDocStringComonicon..Comonicon.command_mainComonicon.(["Comonicon.testComonicon."])
Comonicon.endComonicon.

Comonicon.endComonicon. # Comonicon.TestMarkdownComonicon.

Comonicon.moduleComonicon. Comonicon.TestLazyLoadComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
Comonicon.usingComonicon. Comonicon.ExproniconLiteComonicon.

@Comonicon.testsetComonicon. "Comonicon.lazyloadComonicon." Comonicon.beginComonicon.
    Comonicon.exComonicon. = @Comonicon.exprComonicon. @Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.fComonicon.() Comonicon.endComonicon.
    Comonicon.generatedComonicon. = Comonicon.ComoniconComonicon..lazyload_mComonicon.(Comonicon.MainComonicon., Comonicon.nothingComonicon., :(Comonicon.usingComonicon. Comonicon.PkgComonicon.), Comonicon.exComonicon.)

    @Comonicon.test_exprComonicon. Comonicon.generatedComonicon. == Comonicon.quoteComonicon.
        Comonicon.ifComonicon. !(Comonicon.isemptyComonicon.(Comonicon.ARGSComonicon.)) && Comonicon.ARGSComonicon.[Comonicon.1Comonicon.] == "Comonicon.fComonicon."
            Comonicon.usingComonicon. Comonicon.PkgComonicon.
        Comonicon.endComonicon.

        Comonicon.CoreComonicon..@Comonicon.__doc__Comonicon. @Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.fComonicon.() Comonicon.endComonicon.
    Comonicon.endComonicon.

    Comonicon.exComonicon. = @Comonicon.exprComonicon. @Comonicon.castComonicon. Comonicon.moduleComonicon. Comonicon.nodecmdComonicon.
    Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
    @Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.fComonicon.() Comonicon.endComonicon.
    Comonicon.endComonicon.

    Comonicon.generatedComonicon. = Comonicon.ComoniconComonicon..lazyload_mComonicon.(Comonicon.MainComonicon., Comonicon.nothingComonicon., :(Comonicon.usingComonicon. Comonicon.PkgComonicon.), Comonicon.exComonicon.)
    @Comonicon.test_exprComonicon. Comonicon.generatedComonicon. == Comonicon.quoteComonicon.
        Comonicon.ifComonicon. !(Comonicon.isemptyComonicon.(Comonicon.ARGSComonicon.)) && Comonicon.ARGSComonicon.[Comonicon.1Comonicon.] == "Comonicon.nodecmdComonicon."
            Comonicon.usingComonicon. Comonicon.PkgComonicon.
        Comonicon.endComonicon.

        Comonicon.CoreComonicon..@Comonicon.__doc__Comonicon. @Comonicon.castComonicon. Comonicon.moduleComonicon. Comonicon.nodecmdComonicon.
        Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
        @Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.fComonicon.() Comonicon.endComonicon.
        Comonicon.endComonicon.
    Comonicon.endComonicon.
Comonicon.endComonicon.

Comonicon.endComonicon.
