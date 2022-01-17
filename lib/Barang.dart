class Barang {
  int? id;
  String? kode_barang;
  String? nama_barang;
  String? gambar_barang;
  int qty = 0;

  Barang(
      {this.id,
        this.kode_barang,
        this.nama_barang,
        this.gambar_barang});

  Barang.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kode_barang = json['kode_barang'];
    nama_barang = json['nama_barang'];
    gambar_barang = json['gambar_barang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kode_barang'] = this.kode_barang;
    data['nama_barang'] = this.nama_barang;
    data['gambar_barang'] = this.gambar_barang;
    return data;
  }
}