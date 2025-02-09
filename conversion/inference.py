import argparse

import cv2
import tensorflow as tf
import numpy as np

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="An example of argparse.")
    parser.add_argument('--model', type=str, required=True, help="tflite model path")
    parser.add_argument('--input', type=str, required=True, help="image to test")

    args = parser.parse_args()

    interpreter = tf.lite.Interpreter(model_path=args.model)

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(input_details)
    print(output_details)
    
    interpreter.allocate_tensors()

    im: np.ndarray = cv2.imread(args.input)
    print(f"SHAPE: {im.shape}")
    im = im.astype(np.float32)
    im /= 255
    im = im[None, :, :, :]

    interpreter.set_tensor(input_details[0]['index'], im)
    interpreter.invoke()

    output = interpreter.get_tensor(output_details[0]['index'])

    print(output)