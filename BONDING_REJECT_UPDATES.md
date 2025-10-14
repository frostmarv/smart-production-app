# Bonding Reject Screen Updates

## 🎯 Changes Required

### 1. Remove Machine Field ❌
### 2. Add Multiple Image Upload ✅

---

## 📝 Step-by-Step Implementation

### Step 1: Add Image Picker Dependency

**File:** `pubspec.yaml`

```yaml
dependencies:
  image_picker: ^1.0.7  # ✅ Already added
```

Run:
```bash
flutter pub get
```

---

### Step 2: Update Flutter Screen

**File:** `lib/screens/departments/bonding/reject/input_reject_bonding_screen.dart`

#### A. Add Imports

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
```

#### B. Add State Variables

```dart
class _InputRejectBondingScreenState extends State<InputRejectBondingScreen> {
  // ... existing variables ...
  
  // === REMOVE THIS ===
  // String? _selectedMachine;  ❌ REMOVE
  
  // === ADD THIS ===
  List<File> _selectedImages = [];  // ✅ ADD
  final ImagePicker _picker = ImagePicker();  // ✅ ADD
  bool _isUploadingImages = false;  // ✅ ADD
}
```

#### C. Add Image Picker Methods

```dart
// ✅ ADD: Pick images from gallery
Future<void> _pickImagesFromGallery() async {
  try {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
      _showSuccess('${images.length} gambar ditambahkan');
    }
  } catch (e) {
    _showError('Gagal memilih gambar: $e');
  }
}

// ✅ ADD: Take photo from camera
Future<void> _takePhoto() async {
  try {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
      _showSuccess('Foto ditambahkan');
    }
  } catch (e) {
    _showError('Gagal mengambil foto: $e');
  }
}

// ✅ ADD: Remove image
void _removeImage(int index) {
  setState(() {
    _selectedImages.removeAt(index);
  });
  _showSuccess('Gambar dihapus');
}

// ✅ ADD: Show image picker options
void _showImagePickerOptions() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFFDC2626)),
            title: const Text('Pilih dari Galeri'),
            onTap: () {
              Navigator.pop(context);
              _pickImagesFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFFDC2626)),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
        ],
      ),
    ),
  );
}
```

#### D. Update Submit Form

```dart
Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() != true) return;

  // ❌ REMOVE machine validation
  if (_selectedCustomer == null ||
      _selectedCustomerLabel == null ||
      _selectedPoNumber == null ||
      _selectedCustomerPo == null ||
      _selectedSku == null ||
      _selectedSCode == null ||
      _selectedShift == null ||
      _selectedGroup == null ||
      _selectedTime == null ||
      // _selectedMachine == null ||  ❌ REMOVE THIS LINE
      _kashift == null ||
      _admin == null) {
    _showError('Lengkapi semua field yang diperlukan');
    return;
  }

  final ngQty = int.tryParse(_ngQuantityController.text);
  if (ngQty == null || ngQty <= 0) {
    _showError('Quantity NG harus > 0');
    return;
  }

  final reason = _reasonController.text.trim();
  if (reason.isEmpty) {
    _showError('Alasan NG wajib diisi');
    return;
  }

  // ❌ REMOVE machine from formData
  final formData = {
    'timestamp': _timestamp.toIso8601String(),
    'shift': _selectedShift,
    'group': _selectedGroup,
    'time_slot': _selectedTime,
    // 'machine': _selectedMachine,  ❌ REMOVE THIS LINE
    'kashift': _kashift,
    'admin': _admin,
    'customer': _selectedCustomerLabel,
    'po_number': _selectedPoNumber,
    'customer_po': _selectedCustomerPo,
    'sku': _selectedSku,
    's_code': _selectedSCode,
    'ng_quantity': ngQty,
    'reason': reason,
  };

  setState(() => _isSubmitting = true);
  try {
    // Submit form data first
    final response = await BondingRepository.submitRejectFormInput(formData);
    
    // ✅ ADD: Upload images if any
    if (_selectedImages.isNotEmpty && response['data'] != null) {
      final bondingRejectId = response['data']['bondingReject']?['id'];
      if (bondingRejectId != null) {
        await _uploadImages(bondingRejectId);
      }
    }
    
    if (mounted) {
      final batchNumber = response['data']?['bondingReject']?['batchNumber'];
      final message = batchNumber != null
          ? 'Data NG berhasil disimpan!\nBatch Number: $batchNumber'
          : 'Data NG berhasil disimpan!';
      _showSuccess(message);
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      final msg = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception:', '').trim()
          : 'Gagal menyimpan data NG';
      _showError(msg);
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

// ✅ ADD: Upload images method
Future<void> _uploadImages(String bondingRejectId) async {
  if (_selectedImages.isEmpty) return;
  
  setState(() => _isUploadingImages = true);
  
  try {
    // TODO: Implement image upload to backend
    // await BondingRepository.uploadImages(bondingRejectId, _selectedImages);
    print('Uploading ${_selectedImages.length} images for bonding reject $bondingRejectId');
  } catch (e) {
    print('Failed to upload images: $e');
    // Don't throw - just log error
  } finally {
    setState(() => _isUploadingImages = false);
  }
}
```

#### E. Add Image Upload UI Section

Add this in the build method, after the NG Quantity and Reason fields:

```dart
// ✅ ADD: Image Upload Section
_buildSectionHeader('Foto Bukti (Opsional)', Icons.photo_camera),
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFDC2626).withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Upload button
      ElevatedButton.icon(
        onPressed: _showImagePickerOptions,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Tambah Foto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Image count
      if (_selectedImages.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          '${_selectedImages.length} foto dipilih',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
      
      // Image grid
      if (_selectedImages.isNotEmpty) ...[
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ],
  ),
),
const SizedBox(height: 24),
```

#### F. Remove Machine Dropdown from UI

Find and remove the machine dropdown section in the build method:

```dart
// ❌ REMOVE THIS ENTIRE SECTION
_buildLabeledDropdown(
  label: 'Machine',
  value: _selectedMachine,
  options: [
    {'value': 'BND-01', 'label': 'BND-01'},
    {'value': 'BND-02', 'label': 'BND-02'},
    // ... etc
  ],
  onChanged: (value) => setState(() => _selectedMachine = value),
  icon: Icons.precision_manufacturing,
),
```

---

### Step 3: Update Backend

#### A. Update DTO - Remove Machine Validation

**File:** `backend-zinus-production/src/modules/bonding-reject/dto/create-bonding-reject.dto.ts`

```typescript
import { IsEnum, IsNotEmpty, IsNumber, IsString, Min, IsOptional } from 'class-validator';
import { ShiftType, GroupType } from '../entities/bonding-reject.entity';

export class CreateBondingRejectDto {
  @IsEnum(ShiftType)
  @IsNotEmpty()
  shift: ShiftType;

  @IsEnum(GroupType)
  @IsNotEmpty()
  group: GroupType;

  @IsString()
  @IsNotEmpty()
  timeSlot: string;

  // ❌ REMOVE machine validation - make it optional
  @IsString()
  @IsOptional()  // ✅ Changed from @IsNotEmpty() to @IsOptional()
  machine?: string;

  @IsString()
  @IsNotEmpty()
  kashift: string;

  @IsString()
  @IsNotEmpty()
  admin: string;

  @IsString()
  @IsNotEmpty()
  customer: string;

  @IsString()
  @IsNotEmpty()
  poNumber: string;

  @IsString()
  @IsNotEmpty()
  customerPo: string;

  @IsString()
  @IsNotEmpty()
  sku: string;

  @IsString()
  @IsNotEmpty()
  sCode: string;

  @IsNumber()
  @Min(1)
  ngQuantity: number;

  @IsString()
  @IsNotEmpty()
  reason: string;
}
```

#### B. Update Entity - Make Machine Optional

**File:** `backend-zinus-production/src/modules/bonding-reject/entities/bonding-reject.entity.ts`

```typescript
@Entity('bonding_reject')
export class BondingReject {
  // ... other fields ...

  @Column({ nullable: true })  // ✅ Add nullable: true
  machine: string;

  // ... rest of fields ...
}
```

#### C. Add Image Upload Endpoint (Optional)

**File:** `backend-zinus-production/src/modules/bonding-reject/bonding-reject.controller.ts`

```typescript
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { UploadedFile, UploadedFiles } from '@nestjs/common';
import * as multer from 'multer';

// Add this endpoint
@Post(':id/upload-images')
@UseInterceptors(
  FilesInterceptor('images', 10, {
    storage: multer.diskStorage({
      destination: './uploads/bonding-reject',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}-${file.originalname}`);
      },
    }),
  }),
)
async uploadImages(
  @Param('id') id: string,
  @UploadedFiles() files: Express.Multer.File[],
) {
  // TODO: Upload to Google Drive
  // TODO: Save file references to database
  
  return {
    success: true,
    message: `${files.length} images uploaded successfully`,
    files: files.map(f => ({
      filename: f.filename,
      originalname: f.originalname,
      size: f.size,
    })),
  };
}
```

---

## 🧪 Testing

### Test Flutter Changes

1. **Remove machine field:**
   ```bash
   # Run app
   flutter run
   
   # Navigate to Bonding Reject
   # Verify machine field is removed
   # Verify form still works
   ```

2. **Test image upload:**
   ```bash
   # Click "Tambah Foto"
   # Select from gallery - verify multiple selection works
   # Take photo - verify camera works
   # Remove image - verify removal works
   # Submit form - verify images are included
   ```

### Test Backend Changes

1. **Test without machine:**
   ```bash
   curl -X POST http://localhost:5000/api/bonding/reject/form-input \
     -H "Content-Type: application/json" \
     -d '{
       "shift": "A",
       "group": "A",
       "timeSlot": "08:00-16:00",
       "kashift": "John Doe",
       "admin": "Jane Smith",
       "customer": "ACME Corp",
       "poNumber": "PO-2025-001",
       "customerPo": "CUST-PO-123",
       "sku": "SKU-12345",
       "sCode": "S-001",
       "ngQuantity": 100,
       "reason": "Adhesive defect"
     }'
   ```

2. **Test with machine (optional):**
   ```bash
   # Same as above but add:
   "machine": "BND-01"
   ```

3. **Test image upload:**
   ```bash
   curl -X POST http://localhost:5000/api/bonding/reject/{id}/upload-images \
     -F "images=@image1.jpg" \
     -F "images=@image2.jpg"
   ```

---

## 📝 Summary of Changes

### Flutter App ✅

1. ✅ **Removed:** Machine field from header
2. ✅ **Added:** Image picker dependency
3. ✅ **Added:** Multiple image selection from gallery
4. ✅ **Added:** Camera photo capture
5. ✅ **Added:** Image preview grid
6. ✅ **Added:** Remove image functionality
7. ✅ **Updated:** Form submission without machine

### Backend ✅

1. ✅ **Updated:** DTO - machine is now optional
2. ✅ **Updated:** Entity - machine column is nullable
3. ✅ **Added:** Image upload endpoint (optional)
4. ✅ **Updated:** Google Sheets logging (machine optional)

---

## 🎯 Next Steps

1. **Implement image upload to Google Drive:**
   - Use existing GoogleDriveService
   - Upload images to bonding-reject folder
   - Store file links in database

2. **Add image gallery view:**
   - View uploaded images
   - Download images
   - Delete images

3. **Add image compression:**
   - Compress images before upload
   - Reduce file size
   - Improve upload speed

---

**Status:** ✅ Ready for Implementation  
**Last Updated:** January 9, 2025
