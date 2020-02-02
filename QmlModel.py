from PySide2 import QtCore, QtSql


class SqlQueryModel(QtSql.QSqlQueryModel):
    def data(self, index, role=QtCore.Qt.DisplayRole):
        value = None
        if index.isValid():
            if role < QtCore.Qt.UserRole:
                value = super(SqlQueryModel, self).data(index, role)
            else:
                columnIdx = role - QtCore.Qt.UserRole - 1
                modelIndex = self.index(index.row(), columnIdx)
                value = super(SqlQueryModel, self).data(
                    modelIndex, QtCore.Qt.DisplayRole
                )
        return value

    def roleNames(self):
        roles = dict()
        for i in range(self.record().count()):
            roles[QtCore.Qt.UserRole + i + 1] = self.record().fieldName(i).encode()
        return roles

    @QtCore.Slot(result="QVariantList")
    def roleNameArray(self):
        names = []
        for i in range(self.record().count()):
            names.append(self.record().fieldName(i))
        return names
