Comonicon.moduleComonicon. Comonicon.TestConfigOptionComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
Comonicon.usingComonicon. Comonicon.ConfigurationsComonicon.

@Comonicon.optionComonicon. Comonicon.structComonicon. Comonicon.OptionAComonicon.
    Comonicon.aComonicon.::Comonicon.IntComonicon. = Comonicon.2Comonicon.
    Comonicon.bComonicon.::Comonicon.IntComonicon. = Comonicon.2Comonicon.
Comonicon.endComonicon.

@Comonicon.optionComonicon. Comonicon.structComonicon. Comonicon.OptionBComonicon.
    Comonicon.optionComonicon.::Comonicon.OptionAComonicon.
    Comonicon.cComonicon.::Comonicon.IntComonicon.
Comonicon.endComonicon.

"""
# Comonicon.OptionsComonicon.

- `-Comonicon.cComonicon., --Comonicon.configComonicon. <Comonicon.pathComonicon./Comonicon.toComonicon./Comonicon.optionComonicon./Comonicon.orComonicon./Comonicon.specificComonicon. Comonicon.fieldComonicon.>`: Comonicon.configComonicon..
"""
@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.runComonicon.(; Comonicon.configComonicon.::Comonicon.OptionBComonicon.)
    @Comonicon.testComonicon. Comonicon.configComonicon. == Comonicon.OptionBComonicon.(Comonicon.OptionAComonicon.(Comonicon.1Comonicon., Comonicon.1Comonicon.), Comonicon.1Comonicon.)
Comonicon.endComonicon.

@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.rundefComonicon.(; Comonicon.configComonicon.::Comonicon.OptionAComonicon. = Comonicon.OptionAComonicon.())
    @Comonicon.testComonicon. Comonicon.configComonicon. == Comonicon.OptionAComonicon.(Comonicon.2Comonicon., Comonicon.2Comonicon.)
Comonicon.endComonicon.

@Comonicon.mainComonicon.

@Comonicon.testsetComonicon. "Comonicon.configComonicon. Comonicon.optionsComonicon." Comonicon.beginComonicon.
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.([
        "Comonicon.runComonicon.",
        "--Comonicon.configComonicon..Comonicon.cComonicon.=Comonicon.1Comonicon.",
        "--Comonicon.configComonicon..Comonicon.optionComonicon..Comonicon.aComonicon.=Comonicon.1Comonicon.",
        "--Comonicon.configComonicon..Comonicon.optionComonicon..Comonicon.bComonicon.=Comonicon.1Comonicon.",
    ])

    Comonicon.optComonicon. = Comonicon.TestConfigOptionComonicon..Comonicon.OptionBComonicon.(Comonicon.TestConfigOptionComonicon..Comonicon.OptionAComonicon.(Comonicon.1Comonicon., Comonicon.1Comonicon.), Comonicon.1Comonicon.)
    Comonicon.to_tomlComonicon.("Comonicon.configComonicon..Comonicon.tomlComonicon.", Comonicon.optComonicon.)
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.runComonicon.", "--Comonicon.configComonicon.", "Comonicon.configComonicon..Comonicon.tomlComonicon."])
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.runComonicon.", "-Comonicon.cComonicon.", "Comonicon.configComonicon..Comonicon.tomlComonicon."])

    Comonicon.optComonicon. = Comonicon.TestConfigOptionComonicon..Comonicon.OptionBComonicon.(Comonicon.TestConfigOptionComonicon..Comonicon.OptionAComonicon.(Comonicon.1Comonicon., Comonicon.1Comonicon.), Comonicon.2Comonicon.)
    Comonicon.to_tomlComonicon.("Comonicon.configComonicon..Comonicon.tomlComonicon.", Comonicon.optComonicon.)
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.runComonicon.", "--Comonicon.configComonicon.", "Comonicon.configComonicon..Comonicon.tomlComonicon.", "--Comonicon.configComonicon..Comonicon.cComonicon.=Comonicon.1Comonicon."])

    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.rundefComonicon."])
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.rundefComonicon.", "--Comonicon.configComonicon..Comonicon.aComonicon.=Comonicon.2Comonicon."])
    Comonicon.TestConfigOptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.rundefComonicon.", "--Comonicon.configComonicon..Comonicon.aComonicon.=Comonicon.2Comonicon.", "--Comonicon.configComonicon..Comonicon.bComonicon.=Comonicon.2Comonicon."])
Comonicon.endComonicon.

Comonicon.endComonicon.
