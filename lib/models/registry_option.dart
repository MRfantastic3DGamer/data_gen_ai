/// A labeled value for registry-backed dropdowns (mirrors Unity popup options).
class RegistryOption<T> {
  const RegistryOption({required this.label, required this.value});

  final String label;
  final T value;
}
