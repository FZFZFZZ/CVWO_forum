import argparse
import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow import keras


def main(y_file_path, r_file_path, u_file_path):
    # print(f"Y file path: {y_file_path}")
    # print(f"R file path: {r_file_path}")
    # print(f"U file path: {u_file_path}")


    # find maximum and its index in a numpy array
    def find_max_in_1d_np_array(arr):
        if arr.size == 0:
            return None, None  # Return None if the array is empty
    
        max_index = np.argmax(arr)
        max_value = arr[max_index]
    
        return max_value, max_index
    
    # mean normalisation function
    def normalizeRatings(Y, R):
        sum_of_divisor = np.sum(R, axis = 1)
        sum_of_rows = np.sum(Y * R, axis = 1)
        avg = np.divide(sum_of_rows, sum_of_divisor, where = sum_of_divisor != 0)
        avg = np.tile(avg, (Y.shape[1], 1)).T
        return [np.where(R != 0, Y - avg, 0), avg.T[0]]
    
    
    # import training dataset Y and R
    # Y: rating matrix. R: user rating status matrix.
    Y_file_path = y_file_path
    R_file_path = r_file_path
    df = pd.read_csv(Y_file_path)
    df2 = pd.read_csv(R_file_path, index_col=0)
    index_column = df.iloc[:, 0].to_numpy()
    index_row = df.columns.to_numpy()[1:]
    Y = df.to_numpy().T[1:].T
    R = df2.to_numpy()
    temp_nu = Y.shape[1]
    temp_nm = Y.shape[0]
    
    
    # define vectorised cost function J with regularisation
    def cofi_cost_func_v(X, W, b, Y, R, lambda_):
        j = (tf.linalg.matmul(X, tf.transpose(W)) + b - Y)*R
        J = 0.5 * tf.reduce_sum(j**2) + (lambda_/2) * (tf.reduce_sum(X**2) + tf.reduce_sum(W**2))
        return J
    
    
    # import and process user rating data
    User_file_path = u_file_path
    df3 = pd.read_csv(User_file_path)
    temp = df3.to_numpy()
    user_ratings = np.zeros(temp_nm)
    for i in range(len(temp)):
        index = np.where(index_column == temp[i][0])
        user_ratings[index] = temp[i][1]
    Y = np.c_[user_ratings, Y]
    user_status_array = (user_ratings != 0).astype(int)
    R = np.c_[(user_ratings != 0).astype(int), R]
    Ynorm, Ymean = normalizeRatings(Y, R)
    
    
    # initialise n, X, W and b
    # n: number of features; X: movie vectors; W: user vectors; b: user bias parameters
    nm, nu = Y.shape
    num_features = 100
    tf.random.set_seed(114514)
    W = tf.Variable(tf.random.normal((nu,  num_features),dtype=tf.float32),  name='W')
    X = tf.Variable(tf.random.normal((nm, num_features),dtype=tf.float32),  name='X')
    b = tf.Variable(tf.random.normal((1,          nu),   dtype=tf.float32),  name='b')
    
    
    # Instantiate an optimizer. Learning rate determined by learning rate annealing.
    optimizer = tf.keras.optimizers.legacy.Adam(learning_rate = 3e-3)
    
    
    # Start Learning!!!!!!!!!!!!!!!!!!!!!!!
    iterations = 20
    lambda_ = 1
    for iter in range(iterations):
        with tf.GradientTape() as tape:
    
            # Compute the cost (forward pass included in cost)
            cost_value = cofi_cost_func_v(X, W, b, Ynorm, R, lambda_)
    
        # Use the gradient tape to automatically retrieve
        # the gradients of the trainable variables with respect to the loss
        grads = tape.gradient( cost_value, [X,W,b] )
    
        # Run one step of gradient descent by updating
        # the value of the variables to minimize the loss.
        optimizer.apply_gradients( zip(grads, [X,W,b]) )
    
        # Log periodically.
        # if iter % 20 == 0:
        #    print(f"Training loss at iteration {iter}: {cost_value:0.1f}")
    
    
    # output the result
    p = np.matmul(X.numpy(), np.transpose(W.numpy())) + b.numpy()
    pm = p + np.array([Ymean.T]).T
    my_predictions = pm[:,0]
    
    for i in range(len(my_predictions)):
        if (user_status_array[i] != 0):
           my_predictions[i] = my_predictions[i] - 6  # user has watched this movie, thus no recommendation
    
    index_list = []
    rating_list = []
    
    for i in range(10):
        res = find_max_in_1d_np_array(my_predictions)
        index_list.append(res[1])
        rating_list.append(res[0])
        my_predictions[res[1]] = my_predictions[res[1]] - 6 # for finding the next highest movie
    
    FINALMOVIERECOMMENDATIONLIST = list(map(lambda x: index_column[x], index_list))
    return FINALMOVIERECOMMENDATIONLIST

    # check for accuracy
    # for i in range(len(user_ratings)):
    #    if (user_status_array[i] != 0):
    #        print('[original rating, predicted rating] => ', [user_ratings[i], my_predictions[i]])
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some file paths.')
    parser.add_argument('y_file_path', type=str, help='Path to Y file')
    parser.add_argument('r_file_path', type=str, help='Path to R file')
    parser.add_argument('u_file_path', type=str, help='Path to User file')

    args = parser.parse_args()
    print(main(args.y_file_path, args.r_file_path, args.u_file_path))



