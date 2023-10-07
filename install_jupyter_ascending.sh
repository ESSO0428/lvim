pip install git+https://github.com/ESSO0428/jupyter_ascending.git && \
jupyter nbextension    install jupyter_ascending --sys-prefix --py && \
jupyter nbextension     enable jupyter_ascending --sys-prefix --py && \
jupyter serverextension enable jupyter_ascending --sys-prefix --py
echo "############################"
echo "check sucessfull 1"
jupyter nbextension     list
echo "check sucessfull 2"
jupyter serverextension list
echo "change jupyter config"
yes | jupyter notebook --generate-config
echo "c.NotebookApp.use_redirect_file = False" >> ~/.jupyter/jupyter_notebook_config.py


rm -rf ~/.config/lvim/jupyter_ascending/example.sync.py
rm -rf ~/.config/lvim/jupyter_ascending/example.sync.ipynb
mkdir -p ~/.config/lvim/jupyter_ascending/
cd ~/.config/lvim/jupyter_ascending/ && python -m jupyter_ascending.scripts.make_pair -f --base example && chmod 755 example.sync.py

# Variable inspector in Jupyter

# User :
# From Terminal window install this variable inspector extension.
# pip install jupyter_contrib_nbextensions
# jupyter contrib nbextension install --user

# Virtual environment: 
# If you have created a virtual Python environment with specified Python version 
# and some other libraries you added, activate that environment 
# and enter the following commands. I tested this one and it works.
echo "Install : Variable inspector in Jupyter"
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --sys-prefix

# Activate/Enable:
# If you have installed this Jupyter Notebook extension, then we just simply activate or enable it by:
jupyter nbextension enable varInspector/main

