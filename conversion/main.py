import argparse

import tensorflow as tf
import numpy as np

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="An example of argparse.")
    parser.add_argument('--input', type=str, required=True, help="tf model dir")
    parser.add_argument('--output', type=str, required=True, help="tflite model path")

    args = parser.parse_args()
    converted_model = args.input

    model = tf.saved_model.load(args.input)

    converter = tf.lite.TFLiteConverter.from_saved_model(converted_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    with tf.io.gfile.GFile(args.output, 'wb') as f:
        f.write(tflite_model)