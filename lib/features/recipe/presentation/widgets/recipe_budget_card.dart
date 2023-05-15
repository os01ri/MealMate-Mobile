part of '../pages/recipe_page.dart';

class _RecipeBudget extends StatelessWidget {
  const _RecipeBudget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DetailCardRow(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: AppConfig.borderRadius),
              color: AppColors.mainColor,
              child: const Icon(
                Icons.people_alt_outlined,
                color: Colors.white,
              ).paddingAll(10),
            ),
            const Icon(Icons.remove),
            const Text('2').paddingHorizontal(12),
            const Icon(Icons.add),
          ],
        ),
        _DetailCardRow(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: AppConfig.borderRadius),
              color: AppColors.mainColor,
              child: const Icon(
                Icons.payments_rounded,
                color: Colors.white,
              ).paddingAll(10),
            ),
            Text(
              '250 \$',
              style: const TextStyle().bold,
            ).paddingHorizontal(30),
          ],
        ),
      ],
    );
  }
}

class _DetailCardRow extends StatelessWidget {
  const _DetailCardRow({
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppConfig.borderRadius),
      child: Row(
        children: children,
      ).padding(margin),
    );
  }
}