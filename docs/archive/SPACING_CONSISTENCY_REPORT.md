# Spacing Consistency Report

## Components with Size Attribute

The following components have a "size" attribute:

1. **cascader.ex**
2. **date_picker.ex**
3. **range_picker.ex**
4. **select.ex**
5. **statistic.ex**
6. **steps.ex**
7. **table.ex**
8. **tag.ex**
9. **tree_select.ex**

## Size Values Accepted by Each Component

### Standard Size Components (small/medium/large)
- **cascader**: `["small", "medium", "large"]` (default: "medium")
- **date_picker**: `["small", "medium", "large"]` (default: "medium")
- **range_picker**: `["small", "medium", "large"]` (default: "medium")
- **select**: `["small", "medium", "large"]` (default: "medium")
- **statistic**: `["small", "medium", "large"]` (default: "medium")
- **tag**: `["small", "medium", "large"]` (default: "medium")
- **tree_select**: `["small", "medium", "large"]` (default: "medium")

### Non-Standard Size Components
- **steps**: `["default", "small"]` (default: "default")
- **table**: `["compact", "medium", "large"]` (default: "medium")

## Spacing Implementation Analysis

### Consistent Spacing Pattern (Group 1)
The following components share identical spacing values:
- **cascader**
- **date_picker**
- **range_picker**
- **select**
- **tree_select**

Spacing classes:
- `small`: `"text-sm leading-4 py-2 px-3"`
- `medium`: `"text-sm leading-5 py-2 px-4"`
- `large`: `"text-base leading-6 py-2.5 px-6"`

### Table Component Spacing
- `compact`: `"px-3 py-2"`
- `medium`: `"px-4 py-3"`
- `large`: `"px-6 py-4"`

### Tag Component Spacing
- `small`: `["text-xs leading-4 px-2 py-1"]`
- `medium`: `["text-sm leading-5 px-2.5 py-1.5"]`
- `large`: `["text-base leading-6 px-3 py-2"]`

### Steps Component Spacing
For icon sizes:
- `small`: `"w-6 h-6 text-xs leading-4"`
- `default`: `"w-8 h-8 text-sm leading-5"`

For vertical connector:
- `small`: `"h-8"`
- `default`: `"h-12"`

### Statistic Component Spacing
Title sizes:
- `small`: `"text-xs mb-0.5"`
- `medium`: `"text-sm mb-1"`
- `large`: `"text-base mb-1.5"`

Value sizes:
- `small`: `"text-xl"`
- `medium`: `"text-2xl"`
- `large`: `"text-3xl"`

Prefix/Suffix sizes:
- `small`: `"text-sm"`
- `medium`: `"text-base"`
- `large`: `"text-lg"`

Trend icon sizes:
- `small`: `"w-3 h-3"`
- `medium`: `"w-4 h-4"`
- `large`: `"w-5 h-5"`

## Inconsistencies Found

1. **Size Value Naming**: 
   - Most components use `["small", "medium", "large"]`
   - Steps component uses `["default", "small"]`
   - Table component uses `["compact", "medium", "large"]`

2. **Spacing Values**:
   - Group 1 components (cascader, date_picker, etc.) have consistent spacing
   - Table component has different padding values despite sharing "medium" and "large" sizes
   - Tag component has smaller padding values compared to Group 1
   - Statistic component uses different sizing approach (text sizes instead of padding)

3. **Text Size Patterns**:
   - Group 1: small=`text-sm`, medium=`text-sm`, large=`text-base`
   - Tag: small=`text-xs`, medium=`text-sm`, large=`text-base`
   - Table: No text size specification in padding functions

## Recommendations

1. **Standardize Size Values**: Consider changing:
   - Steps component: `"default"` → `"medium"`
   - Table component: `"compact"` → `"small"`

2. **Create Shared Spacing Constants**: Define a central spacing configuration:
   ```elixir
   @spacing_config %{
     small: %{
       padding: "py-2 px-3",
       text: "text-sm",
       leading: "leading-4"
     },
     medium: %{
       padding: "py-2 px-4",
       text: "text-sm",
       leading: "leading-5"
     },
     large: %{
       padding: "py-2.5 px-6",
       text: "text-base",
       leading: "leading-6"
     }
   }
   ```

3. **Component-Specific Adjustments**: Some components may need different spacing due to their nature:
   - Table cells might need tighter spacing
   - Tags need compact spacing
   - Statistic values need larger text sizes

4. **Documentation**: Add a spacing guide to document the standard spacing values and when to deviate from them.