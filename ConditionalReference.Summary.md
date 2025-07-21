# Reverse Zero-Intrusion Cross-Module Reference System

## Perfect Solution for Package-to-Project Development

We have achieved the ideal solution for cross-module development:

### 🎯 The Requirement

- Submodules use **PackageReferences** (clean, published packages)
- Development needs **ProjectReferences** (real-time debugging)
- **Zero modifications** to submodule files

### ✅ The Solution

A single `Directory.Build.targets` file that:
- **Automatically converts** PackageReferences to ProjectReferences during development
- **Maintains original** PackageReferences for release builds
- **Zero intrusion** - no modifications to any existing files

## How It Works

### Development Mode (Default)
```xml
<!-- In .csproj file -->
<PackageReference Include="Aevatar.Core.Abstractions" />

<!-- Automatically converted to -->
<ProjectReference Include="..\aevatar-station\framework\src\Aevatar.Core.Abstractions\Aevatar.Core.Abstractions.csproj" />
```

### Release Mode
```bash
dotnet build /p:UseLocalProjects=false
```
Uses original PackageReferences as defined

## Implementation

### Directory.Build.targets
Contains two key components:

1. **Package Mappings**
   ```xml
   <PackageProjectMapping Include="Aevatar.Core.Abstractions">
     <ProjectPath>$(AevatarStationPath)\framework\src\Aevatar.Core.Abstractions\Aevatar.Core.Abstractions.csproj</ProjectPath>
   </PackageProjectMapping>
   ```

2. **Conversion Logic**
   - Intercepts before `CollectPackageReferences`
   - Removes matched PackageReferences
   - Adds corresponding ProjectReferences

## Files in Solution

- `Directory.Build.targets` - The core conversion system
- `Directory.Build.props` - Minimal configuration
- `ZeroIntrusion.Guide.md` - Detailed documentation
- `ConditionalReference.Summary.md` - This summary
- `TestProject/` - Demonstration project
- `test-zero-intrusion.sh` - Test script

## Benefits

### Development Experience
- **Real-time debugging** across all modules
- **Immediate code changes** without publishing
- **Full IDE features** (Go to Definition, refactoring, etc.)

### Clean Architecture
- **Submodules stay clean** with PackageReferences
- **Clear boundaries** for deployment
- **Version management** through packages

### Zero Maintenance
- **No file modifications** needed
- **Add new mappings** easily
- **Remove anytime** without traces

## Usage

1. **Setup**: Add `Directory.Build.targets` to root
2. **Develop**: Just run `dotnet build` - automatic ProjectReferences
3. **Release**: Run `dotnet build /p:UseLocalProjects=false` - uses PackageReferences

## Summary

This solution achieves the perfect balance:
- ✅ Clean package definitions in submodules
- ✅ Local project references for development
- ✅ Zero modifications to existing code
- ✅ One file controls everything

The cleanest, most maintainable approach to cross-module development! 🎉 