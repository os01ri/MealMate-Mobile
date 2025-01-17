import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/routing_extensions.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/helper/app_config.dart';
import '../../../../core/helper/cubit_status.dart';
import '../../../../core/localization/localization_class.dart';
import '../../../../core/ui/font/typography.dart';
import '../../../../core/ui/theme/colors.dart';
import '../../../../core/ui/toaster.dart';
import '../../../../core/ui/widgets/error_widget.dart';
import '../../../../core/ui/widgets/main_button.dart';
import '../../../../core/ui/widgets/main_text_field.dart';
import '../../../../dependency_injection.dart';
import '../../../media_service/presentation/widgets/cache_network_image.dart';
import '../../../media_service/presentation/widgets/image_setter_form.dart';
import '../../../store/data/models/cart_item_model.dart';
import '../../../store/data/models/index_ingredients_response_model.dart';
import '../../data/models/recipe_step_model.dart';
import '../../domain/usecases/add_recipe_usecase.dart';
import '../cubit/recipe_cubit.dart';
import '../widgets/app_bar.dart';

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});
  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final RecipeCubit cubit = RecipeCubit();
  String imageUrl = '';
  final List<IngredientModel> ingredients = [];
  var recipeNameController = TextEditingController();

  var quantityController = TextEditingController();
  var typeController = TextEditingController();
  var categoryController = TextEditingController();
  late int categoryId;
  late int typeId;
  var stepTimeController = TextEditingController();
  var stepDescriptionController = TextEditingController();
  var stepNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var servesNotifier = ValueNotifier(1);
    var timeNotifier = ValueNotifier(45);
    var descriptionController = TextEditingController();
    return Scaffold(
      appBar: RecipeAppBar(
        context: context,
        title: serviceLocator<LocalizationClass>().appLocalizations!.createRecipe,
      ),
      body: BlocConsumer<RecipeCubit, RecipeState>(
        bloc: cubit
          ..indexIngredients()
          ..indexCategories()
          ..indexTypes(),
        listener: (context, state) {
          if (state.addRecipeStatus == CubitStatus.success) {
            Toaster.closeLoading();
            context.myPop();
            Toaster.showNotification(
              leading: (_) => const Icon(
                Icons.alarm,
                color: Colors.white,
                size: 35,
              ),
              title: (_) => Text(
                serviceLocator<LocalizationClass>().appLocalizations!.yourRecipePublishedSuccessfully,
                style: const TextStyle(color: Colors.white).bold,
              ),
              subtitle: (_) => Text(
                serviceLocator<LocalizationClass>().appLocalizations!.pleaseWaitForAdminToAccept,
                style: const TextStyle(color: Colors.white).regular,
              ),
              backgroundColor: Colors.green,
            );
          } else if (state.addRecipeStatus == CubitStatus.loading) {
            Toaster.showLoading();
          } else if (state.addRecipeStatus == CubitStatus.failure) {
            Toaster.closeLoading();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: ImageSetterForm(
                      widthFactor: .99,
                      heightFactor: 0.4,
                      onRemove: () {
                        imageUrl = '';
                      },
                      onSuccess: (image) {
                        imageUrl = image;
                      },
                      title: '+',
                    ).hero('picture').paddingAll(10),
                  ).paddingVertical(5),
                  Text(serviceLocator<LocalizationClass>().appLocalizations!.recipeName),
                  MainTextField(
                    hint: serviceLocator<LocalizationClass>().appLocalizations!.recipeName,
                    validator: (recipeName) => !(recipeName != null && recipeName.length > 3)
                        ? serviceLocator<LocalizationClass>().appLocalizations!.pleaseAddRecipeName
                        : null,
                    controller: recipeNameController,
                  ).paddingVertical(5),
                  Text(serviceLocator<LocalizationClass>().appLocalizations!.description),
                  MainTextField(
                    hint: serviceLocator<LocalizationClass>().appLocalizations!.description,
                    validator: (description) => description != null && description.length > 8
                        ? null
                        : serviceLocator<LocalizationClass>().appLocalizations!.pleaseAddRecipeDescription,
                    controller: descriptionController,
                  ).paddingVertical(5),
                  Text(serviceLocator<LocalizationClass>().appLocalizations!.selectCategory),
                  MainTextField(
                    hint: serviceLocator<LocalizationClass>().appLocalizations!.selectCategory,
                    enabled: false,
                    validator: (value) => value != null
                        ? null
                        : serviceLocator<LocalizationClass>().appLocalizations!.pleaseSelectCategory,
                    controller: categoryController,
                  ).paddingVertical(5).onTap(() {
                    print(state.types.length);

                    showModalBottomSheet(
                        context: context,
                        builder: (_) => BlocBuilder<RecipeCubit, RecipeState>(
                              bloc: cubit,
                              builder: (context, innerState) {
                                return SizedBox(
                                  height: .5 * context.height,
                                  child: innerState.indexCategoriesStatus == CubitStatus.success
                                      ? ListView.builder(
                                          itemCount: innerState.categories.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: AppColors.grey, borderRadius: BorderRadius.circular(15)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  if (innerState.categories[index].url != null)
                                                    CachedNetworkImage(
                                                      hash: innerState.categories[index].hash!,
                                                      url: innerState.categories[index].url!,
                                                      width: 50,
                                                      height: 50,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  Text(innerState.categories[index].name!),
                                                ],
                                              ),
                                            ).onTap(() {
                                              categoryController.text = innerState.categories[index].name!;
                                              categoryId = innerState.categories[index].id!;
                                              context.myPop();
                                            });
                                          })
                                      : Center(
                                          child: innerState.indexCategoriesStatus == CubitStatus.failure
                                              ? MainErrorWidget(onTap: () {
                                                  cubit.indexCategories();
                                                })
                                              : const CircularProgressIndicator(),
                                        ),
                                );
                              },
                            ));
                  }),
                  Text(serviceLocator<LocalizationClass>().appLocalizations!.selectType),
                  MainTextField(
                    hint: serviceLocator<LocalizationClass>().appLocalizations!.selectType,
                    enabled: false,
                    validator: (value) =>
                        value != null ? null : serviceLocator<LocalizationClass>().appLocalizations!.pleaseSelectType,
                    controller: typeController,
                  ).paddingVertical(5).onTap(() => showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return BlocBuilder<RecipeCubit, RecipeState>(
                          bloc: cubit,
                          builder: (context, innerState) {
                            return SizedBox(
                              height: .5 * context.height,
                              child: innerState.indexTypesStatus == CubitStatus.success
                                  ? ListView.builder(
                                      itemCount: innerState.types.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: AppColors.grey, borderRadius: BorderRadius.circular(15)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (innerState.types[index].url != null)
                                                CachedNetworkImage(
                                                  hash: innerState.types[index].hash!,
                                                  url: innerState.types[index].url!,
                                                  width: 50,
                                                  height: 50,
                                                  shape: BoxShape.circle,
                                                ),
                                              Text(innerState.types[index].name!),
                                            ],
                                          ),
                                        ).onTap(() {
                                          typeController.text = innerState.types[index].name!;
                                          typeId = innerState.types[index].id!;
                                          context.myPop();
                                        });
                                      })
                                  : Center(
                                      child: innerState.indexTypesStatus == CubitStatus.failure
                                          ? MainErrorWidget(onTap: () {
                                              cubit.indexTypes();
                                            })
                                          : const CircularProgressIndicator.adaptive()),
                            );
                          },
                        );
                      })),
                  _DetailCard(
                    title: serviceLocator<LocalizationClass>().appLocalizations!.serves,
                    value: servesNotifier,
                  ).paddingVertical(5),
                  _DetailCard(
                    title: serviceLocator<LocalizationClass>().appLocalizations!.time,
                    value: timeNotifier,
                  ).paddingVertical(5),
                  Text(
                    serviceLocator<LocalizationClass>().appLocalizations!.ingredients,
                    style: const TextStyle().largeFontSize.bold,
                  ).paddingVertical(10),
                  ...List.generate(
                      state.recipeIngredients.length,
                      (index) => _Ingredient(
                            quantityController: quantityController,
                            cubit: cubit,
                            ingredient: state.recipeIngredients[index].model!,
                          ).paddingAll(5)),
                  Text(
                    serviceLocator<LocalizationClass>().appLocalizations!.addNewIngredient,
                    style: const TextStyle().normalFontSize.extraBold,
                  ).paddingVertical(10).onTap(() => showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: .5 * context.height,
                          child: ListView.builder(
                              itemCount: state.ingredients.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration:
                                      BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CachedNetworkImage(
                                        hash: state.ingredients[index].hash!,
                                        url: state.ingredients[index].url!,
                                        width: 50,
                                        height: 50,
                                        shape: BoxShape.circle,
                                      ),
                                      Text('${state.ingredients[index].name}'),
                                    ],
                                  ),
                                ).onTap(() {
                                  cubit.addOrUpdateIngredientToRecipe(CartItemModel(model: state.ingredients[index]));
                                  log('$ingredients');
                                  context.myPop();
                                });
                              }),
                        );
                      })),
                  Text(
                    serviceLocator<LocalizationClass>().appLocalizations!.steps,
                    style: const TextStyle().largeFontSize.bold,
                  ).paddingVertical(10),
                  ...List.generate(
                      state.steps.length,
                      (index) => Row(
                            children: [
                              MainTextField(
                                enabled: false,
                                controller: TextEditingController(text: state.steps[index].name),
                              ).expand(flex: 2),
                              Container(
                                width: context.width * .06,
                                height: context.width * .06,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Center(child: FittedBox(child: Icon(Icons.remove))),
                              ).paddingAll(10).onTap(() => cubit.deleteStepFromRecipe(state.steps[index].rank!))
                            ],
                          ).paddingAll(5)),
                  Text(
                    serviceLocator<LocalizationClass>().appLocalizations!.addNewStep,
                    style: const TextStyle().normalFontSize.extraBold,
                  ).paddingVertical(10).onTap(() {
                    final formKey = GlobalKey<FormState>();

                    return showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (context) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: SizedBox(
                                  height: .5 * context.height,
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          MainTextField(
                                            textInputAction: TextInputAction.next,
                                            hint: serviceLocator<LocalizationClass>().appLocalizations!.stepName,
                                            validator: (text) => text != null && text.length > 4
                                                ? null
                                                : serviceLocator<LocalizationClass>()
                                                    .appLocalizations!
                                                    .pleaseAddValidStepName,
                                            controller: stepNameController,
                                          ),
                                          MainTextField(
                                            textInputAction: TextInputAction.next,
                                            hint: serviceLocator<LocalizationClass>().appLocalizations!.stepDescription,
                                            validator: (text) => text != null && text.length > 10
                                                ? null
                                                : serviceLocator<LocalizationClass>()
                                                    .appLocalizations!
                                                    .pleaseAddAValidStepDescription,
                                            controller: stepDescriptionController,
                                          ),
                                          MainTextField(
                                            textInputAction: TextInputAction.go,
                                            onSubmitted: (value) {
                                              if (formKey.currentState!.validate()) {
                                                cubit.addStepToRecipe(RecipeStepModel(
                                                    description: stepDescriptionController.text,
                                                    time: int.parse(stepTimeController.text),
                                                    name: stepNameController.text,
                                                    rank: state.steps.length + 1));
                                                stepDescriptionController.clear();
                                                stepTimeController.clear();
                                                stepNameController.clear();
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            hint: serviceLocator<LocalizationClass>().appLocalizations!.stepTime,
                                            keyboardType: TextInputType.number,
                                            validator: (text) => text != null && text.isNotEmpty
                                                ? null
                                                : serviceLocator<LocalizationClass>()
                                                    .appLocalizations!
                                                    .pleaseAddAValidTime,
                                            controller: stepTimeController,
                                          ),
                                          MainButton(
                                              text: serviceLocator<LocalizationClass>().appLocalizations!.addStep,
                                              color: AppColors.mainColor,
                                              onPressed: () {
                                                if (formKey.currentState!.validate()) {
                                                  cubit.addStepToRecipe(RecipeStepModel(
                                                      description: stepDescriptionController.text,
                                                      time: int.parse(stepTimeController.text),
                                                      name: stepNameController.text,
                                                      rank: state.steps.length + 1));
                                                  stepDescriptionController.clear();
                                                  stepTimeController.clear();
                                                  stepNameController.clear();
                                                  Navigator.of(context).pop();
                                                }
                                              })
                                        ]).paddingHorizontal(25),
                                  )),
                            ),
                          );
                        });
                  }),
                  MainButton(
                    text: serviceLocator<LocalizationClass>().appLocalizations!.publish,
                    color: AppColors.mainColor,
                    onPressed: () {
                      if (formKey.currentState!.validate() &&
                          imageUrl.isNotEmpty &&
                          state.steps.isNotEmpty &&
                          state.recipeIngredients.isNotEmpty) {
                        cubit.addRecipe(AddRecipeParams(
                            name: recipeNameController.text,
                            description: descriptionController.text,
                            preparationTime: timeNotifier.value,
                            imageUrl: imageUrl,
                            typeId: typeId,
                            categoryId: categoryId,
                            feeds: servesNotifier.value,
                            steps: state.steps,
                            ingredients: state.recipeIngredients));
                      } else if (state.steps.isEmpty) {
                        Toaster.showToast('Please Add Steps To Recipe');
                      } else if (state.recipeIngredients.isEmpty) {
                        Toaster.showToast('Please Add Ingredients To Recipe');
                      } else if (imageUrl.isEmpty) {
                        Toaster.showToast('Please Add Image');
                      }
                    },
                  ),
                ],
              ).padding(AppConfig.pagePadding),
            ),
          );
        },
      ),
    );
  }
}

class _Ingredient extends StatelessWidget {
  const _Ingredient({
    Key? key,
    required this.ingredient,
    required this.quantityController,
    required this.cubit,
  }) : super(key: key);
  final IngredientModel ingredient;
  final RecipeCubit cubit;
  final TextEditingController quantityController;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MainTextField(
          enabled: false,
          controller: TextEditingController(text: ingredient.name),
        ).expand(flex: 2),
        MainTextField(
          controller: quantityController
            ..text = cubit.state.recipeIngredients
                .where((element) => element.model!.id == ingredient.id)
                .first
                .quantity
                .toString(),
          onChanged: (value) {
            cubit.addOrUpdateIngredientToRecipe(CartItemModel(model: ingredient, quantity: int.parse(value)));
          },
          keyboardType: TextInputType.number,
        ).paddingHorizontal(20).expand(flex: 2),
        Container(
          width: context.width * .06,
          height: context.width * .06,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: const Center(child: FittedBox(child: Icon(Icons.remove))),
        ).paddingAll(10).onTap(() => cubit.deleteIngredientFromRecipe(ingredient.id!)),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.value,
  });

  final String title;
  final ValueNotifier<int> value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(
              Icons.people_alt,
              color: AppColors.mainColor,
            ).paddingAll(5),
          ).paddingAll(12),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle().normalFontSize.bold,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.remove).onTap(() => value.value--),
              ValueListenableBuilder(
                valueListenable: value,
                builder: (_, valueValue, child) {
                  return Text('$valueValue',
                      style: const TextStyle(color: AppColors.lightTextColor).largeFontSize.bold);
                },
              ),
              const Icon(Icons.add).onTap(() => value.value++)
            ],
          ),
        ],
      ),
    );
  }
}
