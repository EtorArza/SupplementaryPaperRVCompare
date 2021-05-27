with open("data/pleda_gradient/results/gradient_results.csv", "w") as f_grad:
    with open("data/pleda_gradient/results/pleda_results.csv", "w") as f_eda:
        with open("data/pleda_gradient/results/results_1000n2_PLEDA_and_Gradient.csv") as f:
            for line in f:
                splitted_line = line.strip("\n").split(";")
                instance_path = "\"data/pleda_gradient/instances/" + splitted_line[0].strip("\"") + "\""
                fitness = splitted_line[3]
                line_to_write = instance_path + ";" + fitness
                print(line_to_write, file=f_grad if "Gradient" in line else f_eda)
