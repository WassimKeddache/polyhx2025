import argparse
from typing import List

import torch
import cv2
import torch.utils
import torch.utils.mobile_optimizer

from inference import YOLOInferenceTorch, YOLOResult

def convert_model_onnx(model: torch.nn.Module, input: torch.Tensor):
    name = "output/model.onnx"
    torch.onnx.export(model, input, name, input_names=["img"], output_names=["bbox"], opset_version=11)
    optmi_model = torch.utils.mobile_optimizer.optimize_for_mobile(model)
    optmi_model._save_for_lite_interpreter("output/model_opti.pt")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="An example of argparse.")
    parser.add_argument('--input', type=str, required=True, help="Input file path")

    args = parser.parse_args()

    inferer = YOLOInferenceTorch("model.ts")

    im = cv2.imread(args.input)
    print(f"IMAGE SHAPE: {im.shape}")
    input = im.copy()

    results: List[YOLOResult] = inferer.predict(input)
    print(results)

    current = results[0]
    for bbox in current:
        bbox.draw_box(im)

    cv2.imwrite("output.png", im)

    input_imgs, params = inferer.preprocess([input])
    print(f"INPUT SHAPE: {input_imgs[0].shape}, DTYPE: {input_imgs.dtype}")

    inferer.model = inferer.model.to(torch.float32)
    convert_model_onnx(inferer.model, input_imgs)