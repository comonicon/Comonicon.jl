Comonicon.moduleComonicon. Comonicon.FakePkgComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.
Comonicon.usingComonicon. Comonicon.PkgTemplatesComonicon.

"""
Comonicon.fakeComonicon. Comonicon.noargumentsComonicon.

"""
@Comonicon.castComonicon. Comonicon.noargumentsComonicon.() = @Comonicon.testComonicon. Comonicon.trueComonicon.

"""
Comonicon.fakeComonicon. Comonicon.addComonicon.

# Comonicon.ArgsComonicon.

- `Comonicon.packageComonicon.`: Comonicon.packageComonicon. Comonicon.toComonicon. Comonicon.addComonicon..
"""
@Comonicon.castComonicon. Comonicon.addComonicon.(Comonicon.packageComonicon.) = @Comonicon.testComonicon. Comonicon.packageComonicon. == "Comonicon.ABCComonicon."

"""
Comonicon.fakeComonicon. Comonicon.rmComonicon.

# Comonicon.ArgsComonicon.

- `Comonicon.packageComonicon.`: Comonicon.packageComonicon. Comonicon.toComonicon. Comonicon.addComonicon..
"""
@Comonicon.castComonicon. Comonicon.rmComonicon.(Comonicon.packageComonicon.) = @Comonicon.testComonicon. Comonicon.packageComonicon. == "Comonicon.ABCComonicon."

"""
Comonicon.fakeComonicon. Comonicon.activateComonicon.

# Comonicon.ArgsComonicon.

- `Comonicon.envComonicon.`: Comonicon.environmentComonicon. Comonicon.toComonicon. Comonicon.activateComonicon..

# Comonicon.FlagsComonicon.

- `-Comonicon.sComonicon., --Comonicon.sharedComonicon.`: Comonicon.fakeComonicon. Comonicon.flagComonicon. Comonicon.shareComonicon..
"""
@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.activateComonicon.(Comonicon.envComonicon.; Comonicon.sharedComonicon.::Comonicon.BoolComonicon. = Comonicon.falseComonicon.)
    @Comonicon.testComonicon. Comonicon.envComonicon. == "Comonicon.fakeComonicon."
    @Comonicon.testComonicon. Comonicon.sharedComonicon. == Comonicon.trueComonicon.
Comonicon.endComonicon.

Comonicon.includeComonicon.("Comonicon.registryComonicon..Comonicon.jlComonicon.")

@Comonicon.mainComonicon.

Comonicon.endComonicon.
